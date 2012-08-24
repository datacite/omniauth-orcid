require File.expand_path("../lib/omniauth-orcid/version", __FILE__)

Gem::Specification.new do |s|
  s.authors       = ["Gudmundur A. Thorisson"]
  s.email         = %q{gthorisson@gmail.com}
  s.name          = "omniauth-orcid"
  s.homepage      = %q{https://github.com/gthorisson/omniauth-orcid}
  s.summary       = %q{ORCID OAuth 2.0 Strategy for OmniAuth 1.0}
  s.date = Date.today
  s.description   = %q{Enables third-party client apps to connect to the ORCID API and access/update protected profiledata }
  s.files         = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md", "Rakefile"]
  s.require_paths = ["lib"]
  s.version       = OmniAuth::ORCID::VERSION
  s.extra_rdoc_files = ["README.md"]


  # Declary dependencies here, rather than in the Gemfile
  s.add_dependency 'omniauth', '~> 1.0'
  s.add_dependency 'omniauth-oauth2', '~> 1.1'

end

