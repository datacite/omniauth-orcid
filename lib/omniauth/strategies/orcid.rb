require 'omniauth-oauth2'
require 'ruby_dig'

# OmniAuth strategy for connecting to the ORCID contributor ID service via the OAuth 2.0 protocol

module OmniAuth
  module Strategies
    class ORCID < OmniAuth::Strategies::OAuth2

      API_VERSION = '2.0'

      option :name, "orcid"

      option :member, false
      option :sandbox, false
      option :provider_ignores_state, false

      option :authorize_options, [:redirect_uri,
                                  :show_login,
                                  :lang,
                                  :given_names,
                                  :family_names,
                                  :email,
                                  :scope]

      args [:client_id, :client_secret]

      def initialize(app, *args, &block)
        super

        @options.client_options.site          = site
        @options.client_options.api_base_url  = api_base_url
        @options.client_options.authorize_url = authorize_url
        @options.client_options.token_url     = token_url
      end

      # available options at https://members.orcid.org/api/get-oauthauthorize
      def authorize_params
        super.tap do |params|
          %w[scope redirect_uri show_login lang given_names family_names email].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end

          # show login form and not registration form by default
          params[:show_login] = 'true' if params[:show_login].nil?

          session['omniauth.state'] = params[:state] if params['state']

          params[:scope] ||= scope
        end
      end

      # URLs for ORCID OAuth: http://members.orcid.org/api/tokens-through-3-legged-oauth-authorization
      def namespace
        if options[:member] && options[:sandbox]
          'sandbox'
        elsif options[:member]
          'production'
        elsif options[:sandbox]
          'public_sandbox'
        else
          'public'
        end
      end

      def site
        case namespace
        when 'sandbox' then 'https://api.sandbox.orcid.org'
        when 'production' then 'https://api.orcid.org'
        when 'public_sandbox' then 'https://pub.sandbox.orcid.org'
        when 'public' then 'https://pub.orcid.org'
        end
      end

      def api_base_url
        site + "/v#{API_VERSION}"
      end

      def root_url
        if options[:sandbox]
          'https://sandbox.orcid.org'
        else
          'https://orcid.org'
        end
      end

      def authorize_url
        root_url + '/oauth/authorize'
      end

      def token_url
        root_url + '/oauth/token'
      end

      def scope
        if options[:member]
          '/read-limited /activities/update /person/update'
        else
          '/authenticate'
        end
      end

      uid { access_token.params["orcid"] }

      info do
        { name: access_token.params["name"],
          email: raw_info[:email],
          first_name: raw_info[:first_name],
          last_name: raw_info[:last_name],
          location: raw_info[:location],
          description: raw_info[:description],
          urls: raw_info[:urls]
        }
      end

      extra do
        skip_info? ? {} : { :raw_info => raw_info }
      end

      def request_info
        @request_info ||= access_token.get( "#{api_base_url}/#{uid}/person", headers: { accept: 'application/json' } ).parsed || {}
      end

      # retrieve all verified email addresses and include visibility (LIMITED vs. PUBLIC)
      # and whether this is the primary email address
      # all other information will in almost all cases be PUBLIC
      def raw_info
        @raw_info ||= {
          first_name: request_info.dig('name', 'given-names', 'value'),
          last_name: request_info.dig('name', 'family-name', 'value'),
          other_names: request_info.dig('other-names', 'other-name').map { |o| o.fetch('content') },
          description: request_info.dig('biography', 'content'),
          location: request_info.dig('addresses', 'address').map { |a| a.dig('country', 'value') }.first,
          email: request_info.dig('emails', 'email')
            .select { |e| e.fetch('verified') }.find { |e| e.fetch('primary') }.to_h.fetch('email', nil),
          urls: request_info.dig('researcher-urls', 'researcher-url').map do |r|
            { r.fetch("url-name", nil) => r.dig('url', 'value') }
          end,
          external_identifiers: request_info.dig('external-identifiers', 'external-identifier').map do |e|
            { 'type' => e.fetch('external-id-type', nil),
              'value' => e.fetch('external-id-value', nil),
              'url' => e.dig('external-id-url', 'value') }
          end
        }
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end

OmniAuth.config.add_camelization 'orcid', 'ORCID'
