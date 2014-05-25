require 'easytag/attributes/ogg'

require_relative 'base'

module EasyTag
  class OggTagger < BaseTagger
    extend OggAttributeAccessors
    extend VorbisAttributes

    initialize_vorbis_attributes

    audio_prop_reader :length
    audio_prop_reader :bitrate
    audio_prop_reader :sample_rate
    audio_prop_reader :channels
    audio_prop_reader :bitrate_maximum
    audio_prop_reader :bitrate_minimum
    audio_prop_reader :bitrate_nominal
    audio_prop_reader :vorbis_version

    def initialize(file)
      @taglib = TagLib::Ogg::Vorbis::File.new(file)
    end
  end
end