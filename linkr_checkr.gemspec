# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'linkr_checkr/version'

Gem::Specification.new do |spec|
  spec.name          = "linkr_checkr"
  spec.version       = LinkrCheckr::VERSION
  spec.authors       = ["Marek Bendik"]
  spec.email         = ["mbendik@blueberryapps.com"]
  spec.description   = %q{Tool for checking dead links on site including js/css}
  spec.summary       = %q{Tool for checking dead links on site including js/css}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri"
  spec.add_dependency "mail"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
