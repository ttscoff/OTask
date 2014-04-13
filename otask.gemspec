# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','otask.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'otask'
  s.version = Otask::VERSION
  s.author = 'Brett Terpstra'
  s.email = 'me@brettterpstra.com'
  s.homepage = 'http://brettterpstra.com/'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A command line tool for creating OmniFocus tasks (Mac)'
  s.description = 'A CLI for OmniFocus task entry with natural language syntax and fuzzy project/context matching.'
  s.license = 'MIT'
# Add your other files here if you make them
  s.files = %w(
bin/otask
lib/otask.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md']
  s.rdoc_options << '--title' << 'doing' << '--main' << 'README.md' << '--markup' << 'markdown' << '-ri'
  s.bindir = 'bin'
  s.executables << 'otask'
  s.add_development_dependency 'rake', '~> 0'
  s.add_development_dependency 'rdoc', '~> 4.1', '>= 4.1.1'
  s.add_development_dependency 'aruba', '~> 0'
  s.add_runtime_dependency('chronic','~> 0.10', '>= 0.10.2')
  s.add_runtime_dependency 'rb-appscript', '~> 0.6', '>= 0.6.1'
  s.add_runtime_dependency 'amatch', '~> 0.3', '>= 0.3.0'

end
