require 'mp3info'
require 'yaml'

require 'easytag/attributes/mp3'

module EasyTag::Interfaces

  class MP3 < Base
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

    def obj_for_frame_id(frame_id)
      Base.obj_or_nil(lookup_first_field(frame_id))
    end

    def lookup_frames(frame_id)
      frames = @id3v2.frame_list(frame_id)
    end

    # get the first field in the first frame
    def lookup_first_field(frame_id)
      frame = lookup_frames(frame_id).first
      warn "frame '#{frame_id}' is not present" if frame.nil?
      frame.field_list.first unless frame.nil?
    end

    EasyTag::Attributes::MP3_ATTRIB_ARGS.each do |attrib_args|
      attrib = EasyTag::Attributes::MP3Attribute.new(attrib_args)
      define_method(attrib.name) do
        instance_variable_get(attrib.ivar) || 
          instance_variable_set(attrib.ivar, attrib.call(self))
      end
    end

  end
end
