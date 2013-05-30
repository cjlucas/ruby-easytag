$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'easytag/version'

Gem::Specification.new do |s|
  s.name        = 'easytag'
  s.version     = EasyTag::VERSION
  s.summary     = 'A simple audio metadata tagging interface'
  s.description = <<-EOF
    EasyTag is an abstraction layer to the TagLib audio tagging library.
    It is designed to provide a simple and consistent API regardless
    of file format being read.
  EOF
  s.authors     = ['Chris Lucas']
  s.email       = ['chris@chrisjlucas.com']
  s.homepage    = 'https://github.com/cjlucas/ruby-easytag'
  s.license     = 'MIT'
  s.files       = `git ls-files | egrep '^[^\.]'`.split(/\r?\n/)
  s.test_files  = s.files.select { |f| f.match(/^test\/.*\.rb$/) }
  s.platform    = Gem::Platform::RUBY

  s.add_runtime_dependency('taglib-ruby', '>= 0.6.0')
  s.add_runtime_dependency('ruby-imagespec', '>= 0.3.1')
  s.add_runtime_dependency('ruby-mp3info', '>= 0.8')

  s.add_development_dependency('rake')
end
