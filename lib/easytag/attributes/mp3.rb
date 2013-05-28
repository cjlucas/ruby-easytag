require 'taglib'

require 'easytag/util'
require 'easytag/attributes/base'

module EasyTag::Attributes
  class MP3Attribute < BaseAttribute
    attr_reader :name, :ivar
    
    def initialize(args)
      @name         = args[:name]
      @id3v2_frames = args[:id3v2_frames] || []
      @id3v1_tag    = args[:id3v1_tag] || nil
      @default      = args[:default]
      @handler      = method(args[:handler])
      @type         = args[:type] || Type::STRING
      @options      = args[:options] || {}
      @ivar         = BaseAttribute.name_to_ivar(@name)

      # fill default options
    
      # ID3 stores boolean values as numeric strings
      #   set to true to enable type casting 
      @options[:is_flag] ||= false
    end

    def call(taglib)
      data = @handler.call(taglib)
      data = type_cast(data)
      post_process(data)
    end

    def type_cast(data)
      case @type
      when Type::INT
        data = data.to_i
      when Type::DATETIME
        data = EasyTag::Utilities.get_datetime(data.to_s)
      end
      
      data
    end

    def post_process(data)
      if @options[:is_flag]
        data = data.to_i == 1 ? true : false
      end

      # fall back to default if data is nil
      BaseAttribute.obj_or_nil(data) || @default
    end

    def frames_for_id(id, taglib)
      taglib.id3v2_tag.frame_list(id)
    end

    def first_frame_for_id(id, taglib)
      frames_for_id(id, taglib).first
    end

    def data_from_frame(frame)
      data = nil
      if frame.class == TagLib::ID3v2::TextIdentificationFrame
        data = frame.field_list.first
      elsif frame.class == TagLib::ID3v2::UnsynchronizedLyricsFrame
        data = frame.text
      end

      data
    end

    #
    # read handlers
    #
    
    def read_v2_frames(taglib)
      frame = nil
      @id3v2_frames.each do |f| 
        frame = first_frame_for_id(f, taglib) if frame.nil?
      end

      if frame.nil?
        data = taglib.id3v1_tag.send(@id3v1_tag) unless @id3v1_tag.nil?
      else
        data = data_from_frame(frame)

        data
      end
    end

    def read_int_pair(taglib)
      int_pair_str = read_v2_frames(taglib).to_s
      EasyTag::Utilities.get_int_pair(int_pair_str)
    end
  end
end

module EasyTag::Attributes
  MP3_ATTRIB_ARGS = [
  # title
  {
    :name         => :title,
    :id3v2_frames => ['TIT2'],
    :id3v1_tag    => :title,
    :handler      => :read_v2_frames,
    :type         => Type::STRING,
  },

  # title_sort_order
  #   TSOT - (v2.4 only)
  #   XSOT - Musicbrainz Picard custom
  {
    :name         => :title_sort_order,
    :id3v2_frames => ['TSOT', 'XSOT'],
    :handler      => :read_v2_frames,
  },

  # subtitle
  {
    :name         => :subtitle,
    :id3v2_frames => ['TIT1'],
    :handler      => :read_v2_frames,
  },

  # artist
  {
    :name         => :artist,
    :id3v2_frames => ['TPE1'],
    :id3v1_tag    => :artist,
    :handler      => :read_v2_frames,
  },

  # artist_sort_order
  #   TSOP - (v2.4 only)
  #   XSOP - Musicbrainz Picard custom
  {
    :name         => :artist_sort_order,
    :id3v2_frames => ['TSOP', 'XSOP'],
    :handler      => :read_v2_frames,
  },

  # album_artist
  {
    :name         => :album_artist,
    :id3v2_frames => ['TPE2'],
    :handler      => :read_v2_frames,
  },

  # album
  {
    :name         => :album,
    :id3v2_frames => ['TALB'],
    :id3v1_tag    => :album,
    :handler      => :read_v2_frames,
  },

  # compilation?
  {
    :name         => :compilation?,
    :id3v2_frames => ['TCMP'],
    :default      => false,
    :handler      => :read_v2_frames,
    :options      => {:is_flag => true},
  },

  # album_sort_order
  #   TSOA - (v2.4 only)
  #   XSOA - Musicbrainz Picard custom
  {
    :name         => :album_sort_order,
    :id3v2_frames => ['TSOA', 'XSOA'],
    :handler      => :read_v2_frames,
  },
  
  # genre
  {
    :name         => :genre,
    :id3v2_frames => ['TCON'],
    :id3v1_tag    => :genre,
    :handler      => :read_v2_frames,
  },

  # disc_subtitle
  {
    :name         => :disc_subtitle,
    :id3v2_frames => ['TSST'],
    :handler      => :read_v2_frames,
  },

  # media
  {
    :name         => :media,
    :id3v2_frames => ['TMED'],
    :handler      => :read_v2_frames,
  },

  # label
  {
    :name         => :label,
    :id3v2_frames => ['TPUB'],
    :handler      => :read_v2_frames,
  },

  # encoded_by
  {
    :name         => :encoded_by,
    :id3v2_frames => ['TENC'],
    :handler      => :read_v2_frames,
  },

  # encoder_settings
  {
    :name         => :encoder_settings,
    :id3v2_frames => ['TSSE'],
    :handler      => :read_v2_frames,
  },

  # group
  {
    :name         => :group,
    :id3v2_frames => ['TIT1'],
    :handler      => :read_v2_frames,
  },

  # composer
  {
    :name         => :composer,
    :id3v2_frames => ['TCOM'],
    :handler      => :read_v2_frames,
  },

  # lyrics
  {
    :name         => :lyrics,
    :id3v2_frames => ['USLT'],
    :handler      => :read_v2_frames,
  },

  # lyricist
  {
    :name         => :lyricist,
    :id3v2_frames => ['TEXT'],
    :handler      => :read_v2_frames,
  },

  # copyright
  {
    :name         => :copyright,
    :id3v2_frames => ['TCOP'],
    :handler      => :read_v2_frames,
  },

  # bpm
  {
    :name         => :bpm,
    :id3v2_frames => ['TBPM'],
    :handler      => :read_v2_frames,
    :type         => Type::INT,
  },

  # track_num
  {
    :name         => :track_num,
    :id3v2_frames => ['TRCK'],
    :id3v1_tag    => :track,
    :default      => [0, 0],
    :handler      => :read_int_pair,
    :type         => Type::INT_LIST, # don't know if this will ever be useful
  },
  
  # disc_num
  {
    :name         => :disc_num,
    :id3v2_frames => ['TPOS'],
    :default      => [0, 0],
    :handler      => :read_int_pair,
    :type         => Type::INT_LIST, # don't know if this will ever be useful
  },

  # original_date
  #   TDOR - orig release date (v2.4 only)
  #   TORY - orig release year (v2.3)
  {
    :name         => :original_date,
    :id3v2_frames => ['TDOR', 'TORY'],
    :handler      => :read_v2_frames,
    :type         => Type::DATETIME,
  },
  ]
end
