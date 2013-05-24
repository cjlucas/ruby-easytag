require 'easytag/base'

module EasyTag
  class File < Base
    attr_reader :file

    def initialize(file)
      @file = file

      if audio_interface_class.nil?
        raise AudioMetadataProxyFileUnsupportedError.new(
          "Couldn't determine which interface to use")
      end

      @interface = audio_interface_class.new(file)
    end

    # block interface
    def self.open(file)
      interface = self.new(file)
      begin
        yield interface if block_given?
      ensure
        interface.close if interface.respond_to?(:close)
      end
    end

    private
    # sufficient for now
    def audio_interface_class
      ext = ::File.extname(@file).downcase[1..-1]
      case ext
      when 'mp3'
        EasyTag::Interfaces::MP3
      when 'mp4', 'm4a', 'aac'
        EasyTag::Interfaces::MP4
      else
        nil
      end
    end
  end
end
