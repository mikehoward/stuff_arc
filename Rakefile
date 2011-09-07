require 'rake'

gem_name = 'stuff_arc'

# snarf gemspec and set version
gem_spec = eval File.new("#{gem_name}.gemspec").read
gem_version = gem_spec.version.to_s

gem_zip = "#{gem_name}_#{gem_version}.zip"
gem_tgz = "#{gem_name}_#{gem_version}.tgz"

task :default => :test

desc "Run unit tests"
task :test do
  system 'ruby tests/*'
  # require "./test/#{gem_name}_base_test"
end

desc "run rdoc to create doc"
task :doc do
  system 'rdoc'
end

desc "build gem"
task :gem do
  system "gem build #{gem_name}.gemspec"
  if 'mike.local' == IO.popen('hostname').read.chomp
    system "cp #{gem_name}-#{gem_version}.gem ~/Rails/GemCache/gems/"
    system "(cd ~/Rails/GemCache ; gem generate_index -d . )"
  end
end

desc "push to github"
task :git_push  do
  system 'git push'
end

desc "push to rubygems"
task :gem_push => :gem do
  system "gem push #{gem_name}-#{gem_version}.gem"
end
