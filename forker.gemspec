# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','forker','constants.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'forker'
  s.version = Forker::VERSION
  s.author = 'Akkuzin Maxim'
  s.email = 'akkmaxon2307@gmail.com'
  s.homepage = 'https://github.com/akkmaxon'
  s.platform = Gem::Platform::RUBY
  s.summary = "No comments..."
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'forker'
  s.add_dependency('nokogiri')
  s.add_dependency('mechanize')
  s.add_dependency('poltergeist')
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
end
