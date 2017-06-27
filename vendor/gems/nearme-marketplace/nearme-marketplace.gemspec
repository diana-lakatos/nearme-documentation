# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nearme-marketplace/version'

Gem::Specification.new do |spec|
  spec.name          = "nearme-marketplace"
  spec.version       = NearmeMarketplace::VERSION
  spec.authors       = ["Michal Janeczek"]
  spec.email         = ["michal@near-me.com"]

  spec.summary       = "Nearme gem for the marketplace builder."
  spec.description   = "http://documentation.near-me.com/gs_install_marketplace_builder.html"
  spec.homepage      = "http://www.near-me.com/"

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = ["nearme-marketplace"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "listen"
  spec.add_dependency "faraday"
  spec.add_dependency "colorize"
end
