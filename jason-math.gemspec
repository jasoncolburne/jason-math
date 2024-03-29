# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jason/math/version'

Gem::Specification.new do |spec|
  spec.name          = 'jason-math'
  spec.version       = Jason::Math::VERSION
  spec.authors       = ['Jason Colburne']
  spec.email         = ['j.colburne@gmail.com']

  spec.summary       = 'Ruby math routines'
  spec.description   = 'Various math routines written in Ruby.'
  spec.homepage      = 'https://github.com/jasoncolburne/jason-math'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.6'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'http://mygemserver.com'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/jasoncolburne/jason-math'
    spec.metadata['changelog_uri'] = 'https://github.com/jasoncolburne/jason-math/blob/main/README.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'benchmark-ips'
  spec.add_development_dependency 'bundler' # , "~> 2.2.17"
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake' # , "~> 10.0"
  spec.add_development_dependency 'rspec' # , "~> 3.0"
  spec.add_development_dependency 'rubocop'

  spec.add_dependency 'rb_heap'
  spec.add_dependency 'securerandom'
end
