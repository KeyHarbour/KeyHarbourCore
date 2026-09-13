require_relative "lib/key_harbour_core/version"

Gem::Specification.new do |spec|
  spec.name        = "key_harbour_core"
  spec.version     = KeyHarbourCore::VERSION
  spec.authors     = [ "Denis Fabien" ]
  spec.email       = [ "denis@keyharbour.ca" ]
  spec.homepage    = "https://keyharbour.ca"
  spec.summary     = "Gem to handle DB for Keyharbour"
  spec.description = "KeyHarbour gives DevSecOps and IT teams one governed place for their operational data: infrastructure state files, inter-pipeline artifacts, software licenses, and tokens. Deploy on-premises, in any cloud, or as SaaS, according to your compliance requirements."
  spec.license     = "GPLv3"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/KeyHarbour/KeyHarbourCore"
  spec.metadata["changelog_uri"] = "https://github.com/KeyHarbour/KeyHarbourCore/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.1.3.1"
  spec.add_dependency "railties", ">= 8.1"
  spec.add_dependency "activerecord", ">= 8.1"
end
