$:.unshift File.expand_path('../lib', __FILE__) unless $: =~ /stuff_arc/
require './lib/stuff_arc'
Gem::Specification.new do |s|
  s.name = "stuff_arc"
  s.author = "Mike Howard"
  s.email = "mike@clove.com"
  s.homepage = "http://github.com/mikehoward/stuff_arc"
  s.summary = "stuff_arc - adds class level archiving/unarchiving to ActiveRecord::Base children"
  s.description = s.summary
  s.files = Dir["{app,lib,tests}/**/*"] + ["LICENSE", "Rakefile", "README.md", 'Gemfile']
  s.version = StuffArc::VERSION
  s.add_dependency('activesupport')
end
