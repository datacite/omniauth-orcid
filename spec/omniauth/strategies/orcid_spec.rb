require 'spec_helper'

describe OmniAuth::Strategies::ORCID do
  let(:request) { double('Request', :params => {}, :cookies => {}, :env => {}) }
  let(:app) {
    lambda do
      [200, {}, ["Hello."]]
    end
  }

  subject do
    OmniAuth::Strategies::ORCID.new(app, 'client_id', 'client_secret', @options || {}).tap do |strategy|
      allow(strategy).to receive(:request) {
        request
      }
    end
  end

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  context 'client options' do
    it 'should have correct name' do
      expect(subject.options.name).to eq('orcid')
    end

    describe "default" do
      it 'should have correct site' do
        expect(subject.options.client_options.site).to eq('http://pub.orcid.org')
      end

      it 'should have correct scope' do
        expect(subject.options.client_options.scope).to eq('/authenticate')
      end

      it 'should have correct token url' do
        expect(subject.options.client_options.token_url).to eq("https://pub.orcid.org/oauth/token")
      end

      it 'should have correct authorize url' do
        expect(subject.options.client_options.authorize_url).to eq('https://orcid.org/oauth/authorize')
      end

      it 'should have correct base url' do
        expect(subject.options.client_options.api_base_url).to eq('http://pub.orcid.org/v1.2')
      end
    end

    describe "sandbox" do
      before do
        @options = { sandbox: true }
      end

      it 'should have correct site' do
        expect(subject.options.client_options.site).to eq("http://pub.sandbox.orcid.org")
      end

      it 'should have correct scope' do
        expect(subject.options.client_options.scope).to eq("/authenticate")
      end

      it 'should have correct token url' do
        expect(subject.options.client_options.token_url).to eq("https://pub.sandbox.orcid.org/oauth/token")
      end

      it 'should have correct authorize url' do
        expect(subject.options.client_options.authorize_url).to eq("https://sandbox.orcid.org/oauth/authorize")
      end

      it 'should have correct base url' do
        expect(subject.options.client_options.api_base_url).to eq("http://pub.sandbox.orcid.org/v1.2")
      end
    end

    describe "member" do
      before do
        @options = { member: true }
      end

      it 'should have correct site' do
        expect(subject.options.client_options.site).to eq('http://api.orcid.org')
      end

      it 'should have correct scope' do
        expect(subject.options.client_options.scope).to eq('/read-limited /activities/update /orcid-bio/update')
      end

      it 'should have correct token url' do
        expect(subject.options.client_options.token_url).to eq("https://api.orcid.org/oauth/token")
      end
    end

    describe "member sandbox" do
      before do
        @options = { member: true, sandbox: true }
      end

      it 'should have correct site' do
        expect(subject.options.client_options.site).to eq("http://api.sandbox.orcid.org")
      end

      it 'should have correct scope' do
        expect(subject.options.client_options.scope).to eq('/read-limited /activities/update /orcid-bio/update')
      end

      it 'should have correct token url' do
        expect(subject.options.client_options.token_url).to eq("https://api.sandbox.orcid.org/oauth/token")
      end
    end

    describe "redirect_uri" do
      it 'should default to nil' do
        @options = {}
        expect(subject.authorize_params['redirect_uri']).to be_nil
      end

      it 'should set the redirect_uri parameter if present' do
        @options = { redirect_uri: 'https://example.com' }
        expect(subject.authorize_params['redirect_uri']).to eq('https://example.com')
      end
    end

    describe "show_login" do
      it 'should default to true' do
        @options = {}
        expect(subject.authorize_params['show_login']).to eq("true")
      end

      it 'should set the show_login parameter if present' do
        @options = { show_login: "false" }
        expect(subject.authorize_params['show_login']).to eq("false")
      end
    end

    describe "lang" do
      it 'should default to nil' do
        @options = {}
        expect(subject.authorize_params['lang']).to be_nil
      end

      it 'should set the lang parameter if present' do
        @options = { lang: 'es' }
        expect(subject.authorize_params['lang']).to eq("es")
      end
    end

    describe "names and email" do
      it 'should default to nil' do
        @options = {}
        expect(subject.authorize_params['given_names']).to be_nil
      end

      it 'should set the names and email parameters if present' do
        @options = { given_names: "Josiah", family_names: "Carberry", email: "josiah@brown.edu" }
        expect(subject.authorize_params["given_names"]).to eq("Josiah")
        expect(subject.authorize_params["family_names"]).to eq("Carberry")
        expect(subject.authorize_params["email"]).to eq("josiah@brown.edu")
      end
    end
  end

  describe 'extra' do
    describe 'raw_info' do
      context 'when skip_info is true' do
        before { subject.options[:skip_info] = true }

        it 'should not include raw_info' do
          expect(subject.extra).not_to have_key(:raw_info)
        end
      end

      # context 'when skip_info is false' do
      #   before { subject.options[:skip_info] = false }

      #   it 'should include raw_info' do
      #     stub_request(:get, "http://pub.orcid.org/v1.2/0000-0002-1825-0097/orcid-bio").
      #       with(:headers => { 'Accept'=>'application/json' }).
      #       to_return(:status => 200, :body => "", :headers => {})
      #     expect(subject.extra[:raw_info]).to eq('sub' => '12345')
      #   end
      # end
    end
  end
end
