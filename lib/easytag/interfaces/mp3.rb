require 'mp3info'

require 'easytag/attributes/mp3'

module EasyTag::Interfaces

  class MP3 < Base
    ATTRIB_ARGS  = EasyTag::Attributes::MP3_ATTRIB_ARGS
    ATTRIB_CLASS = EasyTag::Attributes::MP3Attribute

    def initialize(file)
      @info = TagLib::MPEG::File.new(file)

      add_tdat_to_taglib(file)
    end

    private

    def add_tdat_to_taglib(file)
      # this is required because taglib hash issues with the TDAT+TYER
      # frame (https://github.com/taglib/taglib/issues/127)
      id3v2_hash = ID3v2.new

      File.open(file) do |fp|
        fp.read(3) # read past ID3 identifier
        begin
          id3v2_hash.from_io(fp)
        rescue ID3v2Error => e
          warn 'no id3v2 tags found'
        end
      end

      # delete all TDAT frames (taglib-ruby segfaults when trying to read)
      frames = @info.id3v2_tag.frame_list('TDAT')
      frames.each { |frame| @info.id3v2_tag.remove_frame(frame) } 

      if id3v2_hash['TDAT']
        frame = TagLib::ID3v2::TextIdentificationFrame
          .new('TDAT', TagLib::String::UTF8) 

        frame.text = id3v2_hash['TDAT']
        @info.id3v2_tag.add_frame(frame)
      end
    end

    self.build_attributes(ATTRIB_CLASS, ATTRIB_ARGS)
  end
end
