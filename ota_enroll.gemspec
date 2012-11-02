$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem"s version:
require "ota_enroll/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ota_enroll"
  s.version     = OtaEnroll::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of OtaEnroll."
  s.description = "TODO: Description of OtaEnroll."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "plist", ">=3.1.0"
  s.add_dependency "uuidtools", ">=2.1.3"

  s.add_development_dependency "sqlite3"
end
