# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nearme/version'

Gem::Specification.new do |spec|
  spec.name          = "nearme"
  spec.version       = NearMe::VERSION
  spec.authors       = ["Josef Šimánek"]
  spec.email         = ["josef.simanek@gmail.com"]
  spec.summary       = %q{Mainly NearMe deploy tool.}
  spec.description   = %q{NearMe platform internal AWS tools with nice CLI.}
  spec.homepage      = ""
  spec.license       = "OWN"

  spec.files         = `/usr/bin/git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk"
  spec.add_dependency "rubyzip", "~> 1.1.0"
  spec.add_dependency "thor", "~> 0.19.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
end
