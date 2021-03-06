require_relative 'lib/crudboy/version'

Gem::Specification.new do |spec|
  spec.name          = "crudboy"
  spec.version       = Crudboy::VERSION
  spec.authors       = ["Liu Xiang"]
  spec.email         = ["liuxiang921@gmail.com"]

  spec.summary       = %{CRUD code generator using Rails ActiveRecord}
  spec.description   = %{CRUD code generator using Rails ActiveRecord}
  spec.homepage      = "https://github.com/lululau/crudboy"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")



  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'mysql2', '~> 0.5.3'
  # spec.add_dependency 'pg', '>= 0.18', '< 2.0'
  spec.add_dependency 'sqlite3', '~> 1.4'
  spec.add_dependency 'activerecord', '>= 6.0.3', '< 6.2.0'
  spec.add_dependency 'composite_primary_keys', '~> 12.0.3'
  spec.add_dependency 'activesupport', '~> 6.0.3'
  spec.add_dependency 'net-ssh-gateway', '~> 2.0.0'
  spec.add_dependency 'pry', '~> 0.13.1'
  spec.add_dependency 'pry-byebug', '~> 3.9.0'
  spec.add_dependency 'pry-doc', '>= 1.0.0'
  spec.add_dependency 'rainbow', '~> 3.0.0'
  spec.add_dependency 'terminal-table', '~> 1.8.0'
  spec.add_dependency 'table_print', '~> 1.5.6'
end
