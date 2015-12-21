require 'rubygems/package_task'
require 'rdoc/task'
require 'rake/testtask'
spec = eval(File.read('forker.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end
RDoc::Task.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include("README.rdoc", "lib/**/*.rb", "bin/**/*")
  rdoc.title = 'Forker doc'
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
end
