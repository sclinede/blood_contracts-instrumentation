# frozen_string_literal: true

Gem::Specification.new do |gem|
  gem.name          = 'blood_contracts-instrumentation'
  gem.version       = '0.1.1'
  gem.authors       = ['Sergey Dolganov (sclinede)']
  gem.email         = ['sclinede@evilmartians.com']

  gem.summary       = 'Adds instrumentation to BloodContracts refinement types'
  gem.description   = 'Adds instrumentation to BloodContracts refinement types'
  gem.homepage      = 'https://github.com/sclinede/blood_contracts-core'
  gem.license       = 'MIT'

  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = gem.files.grep(/^spec/)
  gem.extra_rdoc_files = Dir['CODE_OF_CONDUCT.md', 'README.md', 'LICENSE', 'CHANGELOG.md']

  gem.required_ruby_version = '>= 2.4'

  gem.add_runtime_dependency 'blood_contracts-core', '~> 0.4'

  gem.add_development_dependency 'bundler', '~> 2.0'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rubocop', '~> 0.49'
end
