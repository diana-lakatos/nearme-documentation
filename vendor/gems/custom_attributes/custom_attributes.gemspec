# coding: utf-8
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "custom_attributes/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "custom_attributes"
  s.version     = CustomAttributes::VERSION
  s.authors       = ["Maciej Krajowski-Kukiel"]
  s.email         = ["krajek6@gmail.com"]
  s.summary       = %q{Custom attributes for any object.}
  s.description   = %q{Internal way of extending any object with custom attributes}

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', "~> 4.0.0"
  s.add_dependency "pg"

  s.add_development_dependency "minitest"
  s.add_development_dependency "mocha"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "turn"
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'timecop'

end
