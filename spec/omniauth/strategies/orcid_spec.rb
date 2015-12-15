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
      allow(subject).to receive(:request_info).and_return(request_info_hash)
    end

    # it 'should return the uid' do
    #   expect(subject.uid).to eq(1)
    # end
  end

  describe 'info' do
    before do
      allow(subject).to receive(:request_info).and_return(request_info_hash)
    end

    it 'should return name' do
      expect(subject.info[:name]).to eq("Martin Fenner")
    end

    it 'should return first_name' do
      expect(subject.info[:first_name]).to eq("Martin")
    end

    it 'should return last_name' do
      expect(subject.info[:last_name]).to eq("Fenner")
    end

    it 'should return description' do
      expect(subject.info[:description]).to eq("Martin Fenner is the DataCite Technical Director and manages the technical architecture for Datacite as well as DataCite’s technical contributions for the EU-funded THOR project.. From 2012 to 2015 he was technical lead for the PLOS Article-Level Metrics project. He served on the Board of the Open Researcher and Contributor ID (ORCID) initiative from 2010-2012, and worked for ORCID EU in the EC-funded ODIN project from 2012 to 2013. Martin has a medical degree from the Free University of Berlin and is a Board-certified medical oncologist.")
    end
  end

  describe 'raw_info' do
    before do
      allow(subject).to receive(:request_info).and_return(request_info_hash)
    end

    it 'should return other_names' do
      expect(subject.raw_info[:other_names]).to eq([" Martin Hellmut Fenner", "M Fenner", "MH Fenner", "Martin H. Fenner"])
    end
  end
end

private

def request_info_hash
  { 'message-version' => '1.2', 'orcid-profile' => { 'orcid' => nil, 'orcid-id' => nil, 'orcid-identifier' => { 'value' => nil, 'uri' => 'http://orcid.org/0000-0003-1419-2405', 'path' => '0000-0003-1419-2405', 'host' => 'orcid.org' }, 'orcid-deprecated' => nil, 'orcid-preferences' => { 'locale' => 'EN' }, 'orcid-history' => { 'creation-method' => 'WEBSITE', 'completion-date' => { 'value' => 1_349_732_964_340 }, 'submission-date' => { 'value' => 1_349_729_360_270 }, 'last-modified-date' => { 'value' => 1_446_719_619_721 }, 'claimed' => { 'value' => true }, 'source' => nil, 'deactivation-date' => nil, 'verified-email' => { 'value' => true }, 'verified-primary-email' => { 'value' => true }, 'visibility' => nil }, 'orcid-bio' => { 'personal-details' => { 'given-names' => { 'value' => 'Martin' }, 'family-name' => { 'value' => 'Fenner' }, 'credit-name' => { 'value' => 'Martin Fenner', 'visibility' => 'PUBLIC' }, 'other-names' => { 'other-name' => [{ 'value' => ' Martin Hellmut Fenner' }, { 'value' => 'M Fenner' }, { 'value' => 'MH Fenner' }, { 'value' => 'Martin H. Fenner' }], 'visibility' => 'PUBLIC' } }, 'biography' => { 'value' => 'Martin Fenner is the DataCite Technical Director and manages the technical architecture for Datacite as well as DataCite’s technical contributions for the EU-funded THOR project.. From 2012 to 2015 he was technical lead for the PLOS Article-Level Metrics project. He served on the Board of the Open Researcher and Contributor ID (ORCID) initiative from 2010-2012, and worked for ORCID EU in the EC-funded ODIN project from 2012 to 2013. Martin has a medical degree from the Free University of Berlin and is a Board-certified medical oncologist.', 'visibility' => 'PUBLIC' }, 'researcher-urls' => { 'researcher-url' => [{ 'url-name' => { 'value' => 'Blog' }, 'url' => { 'value' => 'http://blog.martinfenner.org' } }, { 'url-name' => { 'value' => 'Twitter' }, 'url' => { 'value' => 'http://twitter.com/mfenner' } }, { 'url-name' => { 'value' => 'My SciENCV' }, 'url' => { 'value' => 'http://www.ncbi.nlm.nih.gov/myncbi/mfenner/cv/1413/' } }], 'visibility' => 'PUBLIC' }, 'contact-details' => { 'email' => [], 'address' => { 'country' => { 'value' => 'DE', 'visibility' => 'PUBLIC' } } }, 'keywords' => nil, 'external-identifiers' => { 'external-identifier' => [{ 'orcid' => nil, 'external-id-orcid' => nil, 'external-id-common-name' => { 'value' => 'ISNI' }, 'external-id-reference' => { 'value' => '000000035060549X' }, 'external-id-url' => { 'value' => 'http://isni.org/000000035060549X' }, 'external-id-source' => nil, 'source' => { 'source-orcid' => { 'value' => nil, 'uri' => 'http://orcid.org/0000-0003-0412-1857', 'path' => '0000-0003-0412-1857', 'host' => 'orcid.org' }, 'source-client-id' => nil, 'source-name' => nil, 'source-date' => nil } }, { 'orcid' => nil, 'external-id-orcid' => nil, 'external-id-common-name' => { 'value' => 'Scopus Author ID' }, 'external-id-reference' => { 'value' => '7006600825' }, 'external-id-url' => { 'value' => 'http://www.scopus.com/inward/authorDetails.url?authorID=7006600825&partnerID=MN8TOARS' }, 'external-id-source' => nil, 'source' => { 'source-orcid' => { 'value' => nil, 'uri' => 'http://orcid.org/0000-0002-5982-8983', 'path' => '0000-0002-5982-8983', 'host' => 'orcid.org' }, 'source-client-id' => nil, 'source-name' => nil, 'source-date' => nil } }], 'visibility' => 'PUBLIC' }, 'delegation' => nil, 'scope' => nil }, 'orcid-activities' => nil, 'orcid-internal' => nil, 'type' => 'USER', 'group-type' => nil, 'client-type' => nil }, 'orcid-search-results' => nil, 'error-desc' => nil }
end
