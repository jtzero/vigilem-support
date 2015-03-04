# -*- encoding: utf-8 -*-
require './lib/vigilem/support/version'

Gem::Specification.new do |s|
  s.name          = 'vigilem-support'
  s.version       = Vigilem::Support::VERSION
  s.platform      = Gem::Platform::RUBY
  s.summary       = 'Support for Vigilem'
  s.description   = 'Support for Vigilem'
  s.authors       = ['jtzero']
  s.email         = 'jtzero511@gmail'
  s.homepage      = 'http://rubygems.org/gems/vigilem-support'
  s.license       = 'MIT'
  
  s.add_dependency 'ffi'
  s.add_dependency 'facets'
  s.add_dependency 'activesupport'
  s.add_dependency 'bundler', '~> 1.7'
  
  s.add_development_dependency 'yard'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'rspec-given'
  s.add_development_dependency 'turnip'
  s.add_development_dependency 'guard-rspec'
  
  s.require_paths = ['lib']
  s.files         = Dir['{lib,spec,ext,test,features,bin}/**/**']
  s.test_files    = s.files.grep(%r<^(test|spec|features)/>)
end
