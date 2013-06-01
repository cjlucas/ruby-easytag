require 'taglib'

require 'easytag/image'
require 'easytag/util'
require 'easytag/attributes/base'

module EasyTag::Attributes
  class MP3Attribute < BaseAttribute
    attr_reader :name, :ivar
    
    def initialize(args)
      super(args)
      @id3v2_frames = args[:id3v2_frames] || []
      @id3v1_tag    = args[:id3v1_tag] || nil

      # fill default options
    
      # ID3 stores boolean values as numeric strings
      #   set to true to enable type casting  (post process)
      @options[:is_flag]    ||= false
      # return entire field list instead of first item in field list
      @options[:field_list] ||= false
    end


    def frames_for_id(id, iface)
      iface.info.id3v2_tag.frame_list(id)
    end

    def first_frame_for_id(id, iface)
      frames_for_id(id, iface).first
    end

    def data_from_frame(frame)
      data = nil
      if frame.is_a?(TagLib::ID3v2::TextIdentificationFrame)
        field_list = frame.field_list
        data = @options[:field_list] ? field_list : field_list.first
      elsif frame.is_a?(TagLib::ID3v2::UnsynchronizedLyricsFrame)
        data = frame.text
      elsif frame.is_a?(TagLib::ID3v2::CommentsFrame)
        data = frame.text
      elsif frame.is_a?(TagLib::ID3v2::AttachedPictureFrame)
        data = EasyTag::Image.new(frame.picture)
        data.desc = frame.description
        data.type = frame.type
        data.mime_type = frame.mime_type
      else
        warn 'no defined frames match the given frame'
      end

      data
    end

    #
    # read handlers
    #
    
    # read_all_id3
    #
    # gets data from each frame id given
    # only falls back to the id3v1 tag if none found
    def read_all_id3(iface)
      frames = []
      @id3v2_frames.each do |f| 
        frames += frames_for_id(f, iface)
      end

      data = []
      # only check id3v1 if no id3v2 frames found
      if frames.empty?
        data << iface.info.id3v1_tag.send(@id3v1_tag) unless @id3v1_tag.nil?
      else
        frames.each { |frame| data << data_from_frame(frame) }
      end

      data
    end

    # read_first_id3
    #
    # Similar to read_all_id3, but optimized for reading only one frame at max
    def read_first_id3(iface)
      frame = nil
      @id3v2_frames.each do |f|
        frame = first_frame_for_id(f, iface) if frame.nil?
      end

      if frame.nil?
        data = iface.info.id3v1_tag.send(@id3v1_tag) unless @id3v1_tag.nil?
      else
        data = data_from_frame(frame)
      end

      data
    end

    def read_int_pair(iface)
      int_pair_str = read_first_id3(iface).to_s
      EasyTag::Utilities.get_int_pair(int_pair_str)
    end

    def read_field_list_as_key_value(iface)
      kv_hash = {}
      frame_data = read_all_id3(iface)

      frame_data.each do |data|
        key = data[0]
        values = data[1..-1]

        key = Utilities.normalize_string(key) if @options[:normalize]
        key = key.to_sym if @options[:to_sym]
        kv_hash[key] = values.count > 1 ? values : values.first
      end

      kv_hash
    end

    def read_date(iface)
      id3v1 = iface.info.id3v1_tag

      v10_year = id3v1.year.to_s if id3v1.year > 0
      v23_year = data_from_frame(first_frame_for_id('TYER', iface))
      v23_date = data_from_frame(first_frame_for_id('TDAT', iface))
      v24_date = data_from_frame(first_frame_for_id('TDRC', iface))

      # check variables in order of importance
      date_str = v24_date || v23_year || v10_year
      # only append v23_date if date_str is currently a year
      date_str << v23_date unless v23_date.nil? or date_str.length > 4
      puts "MP3#date: date_str = \"#{date_str}\"" if $DEBUG

      date_str
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
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # title_sort_order
  #   TSOT - (v2.4 only)
  #   XSOT - Musicbrainz Picard custom
  {
    :name         => :title_sort_order,
    :id3v2_frames => ['TSOT', 'XSOT'],
    :handler      => :read_first_id3,
  },

  # subtitle
  {
    :name         => :subtitle,
    :id3v2_frames => ['TIT3'],
    :handler      => :read_first_id3,
  },

  # artist
  {
    :name         => :artist,
    :id3v2_frames => ['TPE1'],
    :id3v1_tag    => :artist,
    :handler      => :read_first_id3,
  },

  # artist_sort_order
  #   TSOP - (v2.4 only)
  #   XSOP - Musicbrainz Picard custom
  {
    :name         => :artist_sort_order,
    :id3v2_frames => ['TSOP', 'XSOP'],
    :handler      => :read_first_id3,
  },

  # album_artist
  {
    :name         => :album_artist,
    :id3v2_frames => ['TPE2'],
    :handler      => :read_first_id3,
  },

  # album_artist_sort_order
  {
    :name         => :album_artist_sort_order,
    :handler      => lambda { |iface| iface.user_info[:albumartistsort] }
  },

  # album
  {
    :name         => :album,
    :id3v2_frames => ['TALB'],
    :id3v1_tag    => :album,
    :handler      => :read_first_id3,
  },

  # compilation?
  {
    :name         => :compilation?,
    :id3v2_frames => ['TCMP'],
    :handler      => :read_first_id3,
    :type         => Type::BOOLEAN,
    # TODO: remove is_flag option, determine boolean value implicitly 
    :options      => {:is_flag => true},
  },

  # album_sort_order
  #   TSOA - (v2.4 only)
  #   XSOA - Musicbrainz Picard custom
  {
    :name         => :album_sort_order,
    :id3v2_frames => ['TSOA', 'XSOA'],
    :handler      => :read_first_id3,
  },
  
  # genre
  {
    :name         => :genre,
    :id3v2_frames => ['TCON'],
    :id3v1_tag    => :genre,
    :handler      => :read_first_id3,
  },

  # disc_subtitle
  {
    :name         => :disc_subtitle,
    :id3v2_frames => ['TSST'],
    :handler      => :read_first_id3,
  },

  # media
  {
    :name         => :media,
    :id3v2_frames => ['TMED'],
    :handler      => :read_first_id3,
  },

  # label
  {
    :name         => :label,
    :id3v2_frames => ['TPUB'],
    :handler      => :read_first_id3,
  },

  # encoded_by
  {
    :name         => :encoded_by,
    :id3v2_frames => ['TENC'],
    :handler      => :read_first_id3,
  },

  # encoder_settings
  {
    :name         => :encoder_settings,
    :id3v2_frames => ['TSSE'],
    :handler      => :read_first_id3,
  },

  # group
  {
    :name         => :group,
    :id3v2_frames => ['TIT1'],
    :handler      => :read_first_id3,
  },

  # composer
  {
    :name         => :composer,
    :id3v2_frames => ['TCOM'],
    :handler      => :read_first_id3,
  },

  # lyrics
  {
    :name         => :lyrics,
    :id3v2_frames => ['USLT'],
    :handler      => :read_first_id3,
  },

  # lyricist
  {
    :name         => :lyricist,
    :id3v2_frames => ['TEXT'],
    :handler      => :read_first_id3,
  },

  # copyright
  {
    :name         => :copyright,
    :id3v2_frames => ['TCOP'],
    :handler      => :read_first_id3,
  },

  # bpm
  {
    :name         => :bpm,
    :id3v2_frames => ['TBPM'],
    :handler      => :read_first_id3,
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
    :handler      => :read_first_id3,
    :type         => Type::DATETIME,
  },

  # comments
  {
    :name         => :comments,
    :id3v2_frames => ['COMM'],
    :id3v1_tag    => :comment,
    :handler      => :read_all_id3,
    :default      => [],
    :options      => { :compact => true, :delete_empty => true }
  },
  
  # comment
  {
    :name         => :comment,
    :handler      => lambda { |iface| iface.comments.first }
  },

  # album_art
  {
    :name         => :album_art,
    :id3v2_frames => ['APIC'],
    :handler      => :read_all_id3,
    :default      => [],
  },

  # date
  {
    :name         => :date,
    :handler      => :read_date,
    :type         => Type::DATETIME,
  },

  # year
  {
    :name         => :year,
    :handler      => lambda { |iface| iface.date.nil? ? 0 : iface.date.year }
  },

  # user_info
  {
    :name         => :user_info,
    :id3v2_frames => ['TXXX'],
    :handler      => :read_field_list_as_key_value,
    :default      => {},
    :options     => { :normalize => true, 
      :to_sym => true,
      :field_list => true },
  },
  ]
end
