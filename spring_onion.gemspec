# frozen_string_literal: true

require_relative 'lib/spring_onion/version'

Gem::Specification.new do |spec|
  spec.name          = 'spring_onion'
  spec.version       = SpringOnion::VERSION
  spec.authors       = ['winebarrel']
  spec.email         = ['sugawara@winebarrel.jp']

  spec.summary       = 'Log queries with EXPLAIN that may be slow.'
  spec.description   = 'Log queries with EXPLAIN that may be slow.'
  spec.homepage      = 'https://github.com/winebarrel/spring_onion'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord'
  spec.add_dependency 'mysql2'
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
end
