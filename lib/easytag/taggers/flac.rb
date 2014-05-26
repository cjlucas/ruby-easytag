require 'easytag/attributes/flac'

require_relative 'base'

module EasyTag
  class FLACTagger < BaseTagger
    extend FLACAttributeAccessors
    extend VorbisAttributes

    initialize_vorbis_attributes

    audio_prop_reader :length
    audio_prop_reader :bitrate
    audio_prop_reader :sample_rate
    audio_prop_reader :channels
    audio_prop_reader :sample_width
    audio_prop_reader :signature

    def initialize(file)
      @taglib = TagLib::FLAC::File.new(file)
    end
  end
end