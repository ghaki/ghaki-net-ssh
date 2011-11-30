Gem::Specification.new do |s|

  s.name        = 'ghaki-net-ssh'
  s.summary     = 'Secure Shell helpers'
  s.description = 'Ghaki Net SSH is a collection of extensions for the Net SSH gem library.'

  s.version  = IO.read(File.expand_path('VERSION')).chomp

  s.author   = 'Gerald Kalafut'
  s.email    = 'gerald@kalafut.org'
  s.homepage = 'http://github.com/ghaki'

  # rubygem setup
  s.platform                  = Gem::Platform::RUBY
  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = s.name

  # prod deps
  s.add_dependency 'ghaki-account',  '>= 2011.11.29.1'
  s.add_dependency 'ghaki-app',      '>= 2011.11.29.1'
  s.add_dependency 'ghaki-ext-file', '>= 2011.11.29.1'
  s.add_dependency 'ghaki-logger',   '>= 2011.11.29.1'

  s.add_dependency 'highline',        '>= 1.6.1'
  s.add_dependency 'net-ssh',         '>= 2.2.1'
  s.add_dependency 'net-ssh-telnet',  '>= 0.0.2'
  s.add_dependency 'net-sftp',        '>= 2.0.5'

  # devel deps
  s.add_development_dependency 'rspec', '>= 2.6.0'
  s.add_development_dependency 'rdoc',  '>= 3.9.4'
  s.add_development_dependency 'mocha', '>= 0.9.12'

  s.add_development_dependency 'ghaki-match', '>= 2011.11.30.1'

  # rdoc setup
  s.has_rdoc = true
  s.extra_rdoc_files = ['README']

  # manifest
  s.files = Dir['{lib,bin}/**/*'] + %w{ README LICENSE VERSION }
  s.test_files = Dir['spec/**/*_spec.rb','*spec/**/*_helper.rb']

  s.require_path = 'lib'
end
