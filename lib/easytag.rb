require 'bundler/setup'

$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require 'easytag/util'
require 'easytag/file'
require 'easytag/interfaces'

module EasyTag
  class Version
    MAJOR = 0
    MINOR = 1
    TINY  = 0
  end

  VERSION = [Version::MAJOR, Version::MINOR, Version::TINY].join('.')

end
