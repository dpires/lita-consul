Gem::Specification.new do |spec|
  spec.name          = 'lita-consul'
  spec.version       = '0.0.6'
  spec.authors       = ['David Pires']
  spec.email         = ['david.pires@gmail.com']
  spec.description   = 'Lita handler for Consul'
  spec.summary       = 'A lita handler for interacting with Consul'
  spec.homepage      = 'https://github.com/dpires/lita-consul.git'
  spec.license       = 'MIT'
  spec.metadata      = { 'lita_plugin_type' => 'handler' }

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'lita', '>= 4.6'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
end
