require 'mp3info'

require 'easytag'

module EasyTag::Interfaces

  class MP3 < Base
    def initialize(file)
      @info = TagLib::MPEG::File.new(file)
      @id3v1 = @info.id3v1_tag
      @id3v2 = @info.id3v2_tag

      # this is required because taglib hash issues with the TDAT/TYER
      # frame (https://github.com/taglib/taglib/issues/127)
      @id3v2_hash = ID3v2.new

      File.open(file) do |fp|
        fp.read(3) # read past ID3 identifier
        begin
          @id3v2_hash.from_io(fp)
        rescue ID3v2Error => e
          warn 'no id3v2 tags found'
        end
      end

    end

    def title
      obj_for_frame_id('TIT2') or Base.obj_or_nil(@id3v1.title)
    end

    def artist
      obj_for_frame_id('TPE1') or Base.obj_or_nil(@id3v1.artist)
    end

    def album_artist
      obj_for_frame_id('TPE2')
    end

    def album
      obj_for_frame_id('TALB') or Base.obj_or_nil(@id3v1.album)
    end

    # REVIEW: TCON supports genre refining, which we currently don't utilize
    def genre
      obj_for_frame_id('TCON') or Base.obj_or_nil(@id3v1.genre)
    end

    def comments
      return @comments unless @comments.nil?

      comm_frame = lookup_frames('COMM').first
      comm_str = comm_frame ? comm_frame.text : @id3v1.comment

      @comments = Base.obj_or_nil(comm_str)
    end

    def year
      @year ||= @info.tag.year
    end

    # TODO: need to support TDRC tag (new in id3v2.4)
    def date
      return @date unless @date.nil?
      return nil if year.nil? or year == 0

      date_fmt = '%Y'
      date_str = year.to_s

      # check for exact date (ID3v2 gives as MMDD)
      if @id3v2_hash['TDAT']
        date_str << @id3v2_hash['TDAT']
        date_fmt << '%d%m'
      end

      @date = DateTime.strptime(date_str, date_fmt)
    end

    def album_art
      return @album_art unless @album_art.nil?

      @album_art = []
      @id3v2.frame_list('APIC').each do |apic|
        img           = EasyTag::Image.new(apic.picture)
        img.desc      = apic.description
        img.type      = apic.type
        img.mime_type = apic.mime_type

        @album_art << img
      end

      @album_art
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

