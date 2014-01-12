# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitwise_enum/version'

Gem::Specification.new do |spec|
  spec.name          = "bitwise_enum"
  spec.version       = BitwiseEnum::VERSION
  spec.authors       = ["Akira Osada"]
  spec.email         = ["osd.akira@gmail.com"]
  spec.description   = %q{ This is the implementation of OR enum. It has been implemented in bit operation. }
  spec.summary       = spec.description
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
