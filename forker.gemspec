# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','forker','helper.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'forker'
  s.version = Forker::VERSION
  s.author = 'Akkuzin Maxim'
  s.email = 'akkmaxon2307@gmail.com'
  s.homepage = ''
  s.platform = Gem::Platform::RUBY
  s.summary = "No comments..."
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'forker'
  s.add_dependency('nokogiri', '~> 1.6')
  s.add_dependency('capybara', '2.5.0')
  s.add_dependency('minitest', '~> 5.8')
  s.add_dependency('minitest-reporters', '~> 1.1')
  s.add_dependency('poltergeist', '~> 1.8')
  s.add_dependency('mechanize', '~> 2.7')
  s.add_development_dependency('rake')
end
