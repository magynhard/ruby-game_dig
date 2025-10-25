# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'game_dig/version'

Gem::Specification.new do |spec|
  spec.name = "game_dig"
  spec.version = GameDig::VERSION
  spec.authors = ["Matthäus Beyrle"]
  spec.email = ["game_dig.gemspec@mail.magynhard.de"]
  spec.license = "MIT"

  spec.summary = %q{Ruby wrapper gem for node-gamedig to query game servers}
  spec.description = %q{GameDig is a Ruby wrapper gem for the node-gamedig library, which allows querying various game servers for their status and information. The wrapper provides two modes of operation: using the gamedig CLI tool or utilizing a Node.js process via the Nodo library. This gem is useful for developers who want to integrate game server querying capabilities into their Ruby applications.}
  spec.homepage = "https://github.com/magynhard/ruby-game_dig"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
            "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.0.0'

  # Runtime dependencies
  spec.add_runtime_dependency 'nodo', '~> 1.8'
  spec.add_runtime_dependency 'ostruct', '~> 0.6.3'

  # Development dependencies
  spec.add_development_dependency 'bundler', '>= 1.14'
  spec.add_development_dependency 'rake', '>= 10.0'
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'colorize', '0.8.1'
  spec.add_development_dependency 'pry', '0.14.1'
end
