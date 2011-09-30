# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "connfu/version"

Gem::Specification.new do |s|
  s.name = "connfu-client"
  s.version = Connfu::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["connFu team", "Juan de Bravo"]
  s.email = ["devs@connfu.com", "juandebravo@gmail.com"]
  s.homepage = "http://www.github.com/bluevialabs/connfu-client"
  s.summary = %q{connFu DSL to get access to connFu platform}
  s.description = %q{This gem provides a smooth access to connFu capabilities}

  s.rubyforge_project = "connfu"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("activesupport", "~>3.0.8")
  s.add_dependency("rest-client")

  #s.add_runtime_dependency("pry", ">= 0.8.3")
  #s.add_development_dependency("pry-doc")

  s.add_development_dependency("rspec")
  s.add_development_dependency("flog", "~>2.5.1")
  s.add_development_dependency("flay", "~>1.4.2")
  s.add_development_dependency("roodi", "~>2.1.0")
  s.add_development_dependency("reek", "~>1.2.8")
  s.add_development_dependency('simplecov', '>= 0.4.0')
  s.add_development_dependency("webmock")
  s.add_development_dependency("sdoc")
  s.add_development_dependency("metric_fu")
  s.add_development_dependency("metrical")
  s.add_development_dependency("rake")

  s.add_dependency("gli")

end
