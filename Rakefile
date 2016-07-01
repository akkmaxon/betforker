require 'rubygems/package_task'
require 'rdoc/task'
require 'rake/testtask'
spec = eval(File.read('betforker.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end
RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb", "bin/**/*")
  rdoc.title = 'Betforker doc'
end
