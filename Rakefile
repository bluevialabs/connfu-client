require 'bundler'
require 'metric_fu'

Bundler::GemHelper.install_tasks

require 'rdoc/task'

require 'sdoc'

task :default => [:test]

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:test) do |spec|
    spec.skip_bundler = true
    spec.pattern = ['spec/*_spec.rb', 'spec/provisioning/*_spec.rb']
    spec.rspec_opts = '--color --format doc'
end


RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.title = "connFu DSL #{Connfu::VERSION} documentation"

  rdoc.rdoc_files.include('README.rdoc', 'LICENSE.txt')
  
  rdoc.rdoc_files.include('lib/**/*.rb')
  #rdoc.rdoc_files.include('examples/**/*.rb')

  rdoc.options << '-f' << 'sdoc'
  rdoc.options << '-T' << 'connfu'
  rdoc.options << '-c' << 'utf-8'
  rdoc.options << '-g'
  rdoc.options << '-m' << 'README.rdoc'
  
  #rdoc.rdoc_files.include('README*')
end
