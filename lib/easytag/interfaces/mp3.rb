module EasyTag::Interfaces

  class MP3 < Base
    def initialize(file)
      @info = TagLib::MPEG::File.new(file)
      @id3v1 = @info.id3v1_tag
      @id3v2 = @info.id3v2_tag
    end

    def title
      obj_for_frame_id('TIT2')
    end

    def artist
      obj_for_frame_id('TPE1')
    end

    def album_artist
      obj_for_frame_id('TPE2')
    end

    def album
      obj_for_frame_id('TALB')
    end

    # REVIEW: TCON supports genre refining, which we currently don't utilize
    def genre
      obj_for_frame_id('TCON')
    end

    def comments
      comm_frame = @id3v2.frame_list('COMM')[0]
      Base.obj_or_nil(comm_frame.text) unless comm_frame.nil?
    end

    private

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
  end
end

