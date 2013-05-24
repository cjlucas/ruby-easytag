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
      date.nil? ? 0 : date.year
    end

    def date
      return @date unless @date.nil?

      v10_year = @id3v1.year.to_s if @id3v1.year > 0
      v23_year = obj_for_frame_id('TYER')
      v23_date = Base.obj_or_nil(@id3v2_hash['TDAT'])
      v24_date = obj_for_frame_id('TDRC')

      # check variables in order of importance
      date_str = v24_date || v23_year || v10_year
      # only append v23_date if date_str is currently a year
      date_str << v23_date unless v23_date.nil? or date_str.length > 4
      puts "MP3#date: date_str = \"#{date_str}\"" if $DEBUG

      @date = EasyTag::Utilities.get_datetime(date_str)
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

    def track_num
      return @track_num unless @track_num.nil?

      pair = int_pair_for_frame_id('TRCK')
      @track_num = (pair == [0, 0]) ? [@id3v1.track, 0] : pair
    end

    def disc_num
      int_pair_for_frame_id('TPOS')
    end

    private

    # for TPOS and TRCK
    def int_pair_for_frame_id(frame_id)
      str = obj_for_frame_id(frame_id)
      EasyTag::Utilities.get_int_pair(str) unless str.nil?
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
  end
end

