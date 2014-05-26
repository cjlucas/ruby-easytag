require 'bundler/setup'

require 'easytag/util'
require 'easytag/taggers/mp3'
require 'easytag/taggers/mp4'
require 'easytag/taggers/vorbis'
require 'easytag/taggers/flac'
require 'easytag/taggers/ogg'
require 'easytag/taggers/factory'

module EasyTag
  def self.open(file, &block)
    TaggerFactory.open(file, &block)
  end
end