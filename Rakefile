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

# extracted from https://github.com/grosser/project_template
desc "Bump version"
rule /^version:bump:.*/ do |t|
  sh "git status | grep 'nothing to commit'" # ensure we are not dirty
  index = ['major', 'minor','patch'].index(t.name.split(':').last)
  file = 'lib/hash_blue/version.rb'

  version_file = File.read(file)
  old_version, *version_parts = version_file.match(/(\d+)\.(\d+)\.(\d+)/).to_a
  version_parts[index] = version_parts[index].to_i + 1
  new_version = version_parts * '.'
  File.open(file,'w'){|f| f.write(version_file.sub(old_version, new_version)) }

  sh "bundle && git add -f #{file} Gemfile.lock && git commit -m 'bump version to #{new_version}'"
end

