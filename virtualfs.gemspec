# -*- encoding: utf-8 -*-
require File.expand_path('../lib/virtualfs/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Rafał Hirsz"]
  gem.email         = ["rafal@hirsz.co"]
  gem.summary       = %q{Allows accessing remote datastores in a unified way.}
  gem.homepage      = "https://github.com/evoL/virtualfs"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "virtualfs"
  gem.require_paths = ["lib"]
  gem.version       = VirtualFS::VERSION
  gem.license       = 'MIT'

  gem.add_dependency 'github_api', '~> 0.8.0'
  gem.add_dependency 'unicode', '~> 0.4.4'
  gem.add_dependency 'dalli', '~> 2.7'

  gem.add_development_dependency 'rspec', '~> 2.12'
  gem.add_development_dependency 'fakefs', '~> 0.4'
end
