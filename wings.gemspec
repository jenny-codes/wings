lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wings/version'

Gem::Specification.new do |spec|
  spec.name          = 'wings-framework'
  spec.version       = Wings::VERSION
  spec.authors       = ['Jenny Shih']
  spec.email         = ['jinghua.shih@gmail.com']

  spec.summary       = 'a Rack-based web framework inspired by Rails, with abridged functionality and a better name.'
  spec.description   = 'Wings is a Rack-based, MVC framework with REST implementation, also supports ORM for database manipulation.'
  spec.homepage      = 'https://github.com/jing-jenny-shih/wings'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/jing-jenny-shih/wings'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rack-test', '~> 1.1'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'pry', '~> 0.12.2'
  spec.add_development_dependency 'rr', '~> 1.2'

  spec.add_runtime_dependency 'multi_json', '~> 1.11'
  spec.add_runtime_dependency 'sqlite3', '~> 1.3'
  spec.add_runtime_dependency 'erubis', '~> 2.7'
  spec.add_runtime_dependency 'rack', '>= 1.6.4'
end
