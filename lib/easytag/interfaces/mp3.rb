require 'mp3info'
require 'yaml'

require 'easytag/attributes/mp3'

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

    def album_artist_sort_order
      user_info[:albumartistsort]
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

    def user_info
      return @user_info unless @user_info.nil?

      @user_info = {}
      lookup_frames('TXXX').each do |frame|
        key, value = frame.field_list
        key = EasyTag::Utilities.normalize_string(key)
        @user_info[key.to_sym] = value
      end

      @user_info
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

    EasyTag::Attributes::MP3_ATTRIB_ARGS.each do |attrib_args|
      attrib = EasyTag::Attributes::MP3Attribute.new(attrib_args)
      define_method(attrib.name) do
        instance_variable_get(attrib.ivar) || 
          instance_variable_set(attrib.ivar, attrib.call(@info))
      end
    end

  end
end
