# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','forker','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'forker'
  s.version = Forker::VERSION
  s.author = 'Akkuzin Maxim'
  s.email = 'akkmaxon2307@gmail.com'
  s.homepage = ''
  s.platform = Gem::Platform::RUBY
  s.summary = "An app that looking for available bukmeker's forks"
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
#  s.has_rdoc = true
#  s.extra_rdoc_files = ['README.rdoc','forker.rdoc']
#  s.rdoc_options << '--title' << 'forker' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'forker'
  s.add_dependency('nokogiri')
  s.add_dependency('capybara')
  s.add_dependency('poltergeist')
  s.add_dependency('mechanize')
  s.add_development_dependency('rake', '~> 10.4.2')
  s.add_development_dependency('rdoc', '~> 4.2')
  s.add_development_dependency('aruba', '~> 0.7.4')
end
