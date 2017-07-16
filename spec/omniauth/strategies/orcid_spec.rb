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
        expect(subject.options.client_options.site).to eq('https://pub.orcid.org')
      end

      it 'should have correct scope' do
        expect(subject.authorize_params['scope']).to eq('/authenticate')
      end

      it 'should have correct token url' do
        expect(subject.options.client_options.token_url).to eq("https://orcid.org/oauth/token")
      end

      it 'should have correct authorize url' do
        expect(subject.options.client_options.authorize_url).to eq('https://orcid.org/oauth/authorize')
      end

      it 'should have correct base url' do
        expect(subject.options.client_options.api_base_url).to eq('https://pub.orcid.org/v2.0')
      end
    end

    describe "sandbox" do
      before do
        @options = { sandbox: true }
      end

      it 'should have correct site' do
        expect(subject.options.client_options.site).to eq("https://pub.sandbox.orcid.org")
      end

      it 'should have correct scope' do
        expect(subject.authorize_params['scope']).to eq("/authenticate")
      end

      it 'should have correct token url' do
        expect(subject.options.client_options.token_url).to eq("https://sandbox.orcid.org/oauth/token")
      end

      it 'should have correct authorize url' do
        expect(subject.options.client_options.authorize_url).to eq("https://sandbox.orcid.org/oauth/authorize")
      end

      it 'should have correct base url' do
        expect(subject.options.client_options.api_base_url).to eq("https://pub.sandbox.orcid.org/v2.0")
      end
    end

    describe "member" do
      before do
        @options = { member: true }
      end

      it 'should have correct site' do
        expect(subject.options.client_options.site).to eq('https://api.orcid.org')
      end

      it 'should have correct scope' do
        expect(subject.authorize_params['scope']).to eq('/read-limited /activities/update /person/update')
      end

      it 'should have correct token url' do
        expect(subject.options.client_options.token_url).to eq("https://orcid.org/oauth/token")
      end
    end

    describe "member sandbox" do
      before do
        @options = { member: true, sandbox: true }
      end

      it 'should have correct site' do
        expect(subject.options.client_options.site).to eq("https://api.sandbox.orcid.org")
      end

      it 'should have correct scope' do
        expect(subject.authorize_params['scope']).to eq('/read-limited /activities/update /person/update')
      end

      it 'should have correct token url' do
        expect(subject.options.client_options.token_url).to eq("https://sandbox.orcid.org/oauth/token")
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

    describe "scope" do
      it 'should default to nil' do
        @options = {}
        expect(subject.authorize_params['scope']).to eq("/authenticate")
      end

      it 'should set the scope parameter if present' do
        @options = { scope: '/read-limited' }
        expect(subject.authorize_params['scope']).to eq("/read-limited")
      end
    end
  end

  context 'info' do
    let(:params) { JSON.parse(IO.read(fixture_path + 'access_token.json')) }
    let(:access_token) { OpenStruct.new("params" => params) }
    let(:request_info) { JSON.parse(IO.read(fixture_path + 'request_info.json')) }

    before do
      allow(subject).to receive(:access_token).and_return(access_token)
      allow(subject).to receive(:request_info).and_return(request_info)
    end

    it 'should return name' do
      expect(subject.info[:name]).to eq('Martin Fenner')
    end

    it 'should return first_name' do
      expect(subject.info[:first_name]).to eq('Martin')
    end

    it 'should return last_name' do
      expect(subject.info[:last_name]).to eq('Fenner')
    end

    it 'should return description' do
      expect(subject.info[:description]).to start_with('Martin Fenner is the DataCite Technical Director')
    end

    it 'should return location' do
      expect(subject.info[:location]).to eq("DE")
    end

    it 'should return email' do
      expect(subject.info[:email]).to eq( "martin.fenner@datacite.org")
    end

    it 'should return urls' do
      expect(subject.info[:urls]).to eq([{"Blog"=>"http://blog.martinfenner.org"}])
    end
  end

  context 'raw_info' do
    let(:params) { JSON.parse(IO.read(fixture_path + 'access_token.json')) }
    let(:access_token) { OpenStruct.new("params" => params) }
    let(:request_info) { JSON.parse(IO.read(fixture_path + 'request_info.json')) }

    before do
      allow(subject).to receive(:access_token).and_return(access_token)
      allow(subject).to receive(:request_info).and_return(request_info)
    end

    it 'should not include raw_info' do
      subject.options[:skip_info] = true
      expect(subject.extra).not_to have_key(:raw_info)
    end

    it 'should return first_name' do
      expect(subject.extra.dig(:raw_info, :first_name)).to eq('Martin')
    end

    it 'should return last_name' do
      expect(subject.extra.dig(:raw_info, :last_name)).to eq('Fenner')
    end

    it 'should return other_names' do
      expect(subject.extra.dig(:raw_info, :other_names)).to eq(["Martin Hellmut Fenner"])
    end

    it 'should return description' do
      expect(subject.extra.dig(:raw_info, :description)).to start_with('Martin Fenner is the DataCite Technical Director')
    end

    it 'should return location' do
      expect(subject.extra.dig(:raw_info, :location)).to eq("DE")
    end

    it 'should return email' do
      expect(subject.extra.dig(:raw_info, :email)).to eq( "martin.fenner@datacite.org")
    end

    it 'should return urls' do
      expect(subject.extra.dig(:raw_info, :urls)).to eq([{"Blog"=>"http://blog.martinfenner.org"}])
    end

    it 'should return external_identifiers' do
      expect(subject.extra.dig(:raw_info, :external_identifiers)).to eq([{"type"=>"GitHub", "value"=>"mfenner", "url"=>"https://github.com/mfenner"}])
    end
  end
end
