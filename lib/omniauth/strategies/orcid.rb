require 'omniauth-oauth2'

# OmniAuth strategy for connecting to the ORCID contributor ID service via the OAuth 2.0 protocol

module OmniAuth
  module Strategies
    class ORCID < OmniAuth::Strategies::OAuth2

      API_VERSION = '1.2'

      option :name, "orcid"

      option :member, false
      option :sandbox, false
      option :provider_ignores_state, true

      option :authorize_options, [:redirect_uri,
                                  :show_login,
                                  :lang,
                                  :given_names,
                                  :family_names,
                                  :email,
                                  :orcid]

      args [:client_id, :client_secret]

      def initialize(app, *args, &block)
        super

        @options.client_options.site          = site
        @options.client_options.api_base_url  = api_base_url
        @options.client_options.authorize_url = authorize_url
        @options.client_options.token_url     = token_url
        @options.client_options.scope         = scope
      end

      # available options at https://members.orcid.org/api/get-oauthauthorize
      def authorize_params
        super.tap do |params|
          options[:authorize_options].each do |k|
            params[k] = request.params[k.to_s] unless [nil, ''].include?(request.params[k.to_s])
          end

          # show login form and not registration form by default
          params[:show_login] = 'true' if params[:show_login].nil?

          session['omniauth.state'] = params[:state] if params['state']
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
        when 'sandbox' then 'http://api.sandbox.orcid.org'
        when 'production' then 'http://api.orcid.org'
        when 'public_sandbox' then 'http://pub.sandbox.orcid.org'
        when 'public' then 'http://pub.orcid.org'
        end
      end

      def api_base_url
        if options[:sandbox]
          "http://pub.sandbox.orcid.org/v#{API_VERSION}"
        else
          "http://pub.orcid.org/v#{API_VERSION}"
        end
      end

      def authorize_url
        if options[:sandbox]
          'https://sandbox.orcid.org/oauth/authorize'
        else
          'https://orcid.org/oauth/authorize'
        end
      end

      def token_url
        case namespace
        when 'sandbox' then 'https://api.sandbox.orcid.org/oauth/token'
        when 'production' then 'https://api.orcid.org/oauth/token'
        when 'public_sandbox' then 'https://pub.sandbox.orcid.org/oauth/token'
        when 'public' then 'https://pub.orcid.org/oauth/token'
        end
      end

      def scope
        if options[:member]
          '/orcid-profile/read-limited /orcid-works/create /orcid-bio/external-identifiers/create /affiliations/create /funding/create'
        else
          '/authenticate'
        end
      end

      uid { access_token.params["orcid"] }

      info do
        { name: raw_info[:name],
          email: raw_info[:email],
          first_name: raw_info[:first_name],
          last_name: raw_info[:last_name],
          description: raw_info[:description],
          urls: raw_info[:urls]
        }
      end

      extra do
        skip_info? ? {} : { :raw_info => raw_info }
      end

      def request_info
        client.request(:get, "#{api_base_url}/#{uid}/orcid-bio", headers: { accept: 'application/json' }).parsed || {}
      end

      def raw_info
        orcid_bio = request_info.fetch('orcid-profile', nil).to_h.fetch('orcid-bio', {})

        emails = orcid_bio.fetch('contact-details', nil).to_h.fetch('email', nil)
        email = nil

        if emails.is_a? Array

          emails.each do |e|

            next unless e['visibility'] == "PUBLIC"
            next unless e['verified']
            email = e['value']
            break

          end

        end

        { name: orcid_bio.fetch('personal-details', nil).to_h.fetch('credit-name', nil).to_h.fetch('value', nil),
          first_name: orcid_bio.fetch('personal-details', nil).to_h.fetch('given-names', nil).to_h.fetch('value', nil),
          last_name: orcid_bio.fetch('personal-details', nil).to_h.fetch('family-name', nil).to_h.fetch('value', nil),
          other_names: orcid_bio.fetch('personal-details', nil).to_h.fetch('other-names', nil).to_h.fetch('other-name', [{}]).map { |other_name| other_name.fetch('value', nil) },
          description: orcid_bio.fetch('biography', nil).to_h.fetch('value', nil),
          urls: {},
          email: email
        }
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end

OmniAuth.config.add_camelization 'orcid', 'ORCID'
