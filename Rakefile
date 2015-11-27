require 'rake'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

exclude_paths = [ 
  'spec/**/*',
  'pkg/**/*',
  'tests/**/*',
  'vagrant/**/*'
]

Rake::Task[:lint].clear
PuppetSyntax.exclude_paths = exclude_paths
PuppetLint.configuration.fail_on_warnings
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetLint.configuration.with_context = true
PuppetLint.configuration.relative = true
PuppetLint.configuration.send('disable_class_inherits_from_params_class')

task :default => [:lint]

