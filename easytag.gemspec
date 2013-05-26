$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'easytag/version'

MDOWN_URL = /\[([^\]]+)\]\(([^\)]+)\)/
def strip_md_links(text)
  until (match_data=text.match(MDOWN_URL)).nil?
    text.sub!(match_data[0], match_data[1])
  end

  text
end

Gem::Specification.new do |s|
  s.name        = 'easytag'
  s.version     = EasyTag::VERSION
  s.summary     = 'A simple audio metadata tagging interface'
  s.description = strip_md_links(`cat README.md | head -n 1`).strip
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
