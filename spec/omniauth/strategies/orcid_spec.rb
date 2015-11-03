require 'spec_helper'

describe OmniAuth::Strategies::ORCID do
  subject { OmniAuth::Strategies::ORCID.new({}) }

  describe 'client options' do
    it 'should have correct name' do
      expect(subject.options.name).to eq('orcid')
    end

    it 'should have correct site' do
      expect(subject.options.client_options.site).to eq('http://pub.orcid.org')
    end

    it 'should have correct authorize url' do
      expect(subject.options.client_options.authorize_url).to eq('https://orcid.org/oauth/authorize')
    end

    it 'should have correct scope' do
      expect(subject.options.client_options.scope).to eq('/authenticate')
    end
  end

  describe 'uid' do
    before do
      allow(subject).to receive(:raw_info).and_return(raw_info_hash)
    end

    it 'should return the uid' do
      expect(subject.uid).to eq(raw_info_hash['orcid'])
    end
  end

  describe 'info' do
    before do
      allow(subject).to receive(:raw_info).and_return(raw_info_hash)
    end

    it 'should returns the name' do
      expect(subject.info[:name]).to eq(raw_info_hash['name'])
    end
  end
end

private

def raw_info_hash
  {
    "name" => "Josiah Carberry",
    "access_token" => "e6394ba4-34bd-43a8-8c3d-a99752fe0bf9",
    "expires_in" => 631138518,
    "token_type" => "bearer",
    "orcid" => "0000-0002-1825-0097",
    "scope" => "/authenticate",
    "refresh_token" => "c07df09f-2015-4b88-a387-61b7e2a89fb0"
  }
end
