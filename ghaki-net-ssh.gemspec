Gem::Specification.new do |s|
  s.name     = 'ghaki-net-ssh'
  s.summary  = 'Secure Shell helper'
  s.description = 'Ghaki Net SSH is a collection of extensions for the Net SSH gem library.'

  s.version  = IO.read(File.expand_path('VERSION')).chomp
  s.platform = Gem::Platform::RUBY

  s.author   = 'Gerald Kalafut'
  s.email    = 'gerald@kalafut.org'
  s.homepage = 'http://ghaki.com/'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project = s.name

  s.add_dependency 'ghaki-account', '>= 1.1.4'
  s.add_dependency 'ghaki-app',     '>= 1.1.3'
  s.add_dependency 'ghaki-core',    '>= 2011.10.09.1'
  s.add_dependency 'ghaki-logger',  '>= 2011.10.26.1'

  s.add_dependency 'highline',        '>= 1.6.1'
  s.add_dependency 'net-ssh',         '>= 2.2.1'
  s.add_dependency 'net-ssh-telnet',  '>= 0.0.2'
  s.add_dependency 'net-sftp',        '>= 2.0.5'

  s.add_development_dependency 'rspec', '>= 2.6.0'
  s.add_development_dependency 'rdoc',  '>= 3.9.4'
  s.add_development_dependency 'mocha', '>= 0.9.12'

  s.has_rdoc = true
  s.extra_rdoc_files = ['README']

  s.files = Dir['{lib,bin}/**/*'] + %w{ README LICENSE VERSION }
  s.test_files = Dir['spec/**/*_spec.rb','*spec/**/*_helper.rb']
  s.require_path = 'lib'
end
