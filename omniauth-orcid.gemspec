require "date"
require File.expand_path("../lib/omniauth/orcid/version", __FILE__)

Gem::Specification.new do |s|
  s.authors       = ["Gudmundur A. Thorisson", "Martin Fenner"]
  s.email         = ["gthorisson@gmail.com", "martin.fenner@datacite.org"]
  s.name          = "omniauth-orcid"
  s.homepage      = "https://github.com/datacite/omniauth-orcid"
  s.summary       = "ORCID OAuth 2.0 Strategy for OmniAuth 1.0"
  s.date          = Date.today
  s.description   = "Enables third-party client apps to connect to the ORCID API and access/update protected profile data"
  s.require_paths = ["lib"]
  s.version       = OmniAuth::Orcid::VERSION
  s.extra_rdoc_files = ["README.md"]
  s.license       = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  # Declary dependencies here, rather than in the Gemfile
  s.add_dependency 'omniauth-oauth2', '~> 1.3.1'
  s.add_development_dependency 'bundler', '~> 1.0'
end
