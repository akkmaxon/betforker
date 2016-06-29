# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','forker','version.rb'])
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
  s.add_dependency('nokogiri', '~> 1.6')
  s.add_dependency('mechanize', '~> 2.7')
  s.add_dependency('poltergeist', '1.9')
  s.add_dependency('thor', '~> 0.19')
  s.add_dependency('highline', '~> 1.7')
  s.add_development_dependency('rake', '~> 11.2')
  s.add_development_dependency('rspec', '~> 3.4')
end
