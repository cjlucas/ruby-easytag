require 'taglib'

require 'easytag/image'
require 'easytag/util'
require 'easytag/attributes/base'

module EasyTag
  module MP3AttributeAccessors
    include BaseAttributeAccessors

    def single_tag_reader(attr_name, id3v2_frames = nil, id3v1_tag = nil, **opts)
      id3v2_frames = Array(id3v2_frames)
      define_method(attr_name) do
        v = self.class.read_first_tag(taglib, id3v2_frames, id3v1_tag, opts)
        self.class.post_process(v, opts)
      end
    end

    def all_tags_reader(attr_name, id3v2_frames = nil, id3v1_tag = nil, **opts)
      id3v2_frames = Array(id3v2_frames)
      define_method(attr_name) do
        v = self.class.read_all_tags(taglib, id3v2_frames, id3v1_tag, opts)
        self.class.post_process(v, opts)
      end
    end

    def audio_prop_reader(attr_name, prop_name = nil, **opts)
      prop_name = attr_name if prop_name.nil?
      define_method(attr_name) do
        v = self.class.read_audio_property(taglib, prop_name)
        self.class.post_process(v, opts)
      end
    end

    def user_info_reader(attr_name, key = nil, **opts)
      key = attr_name if key.nil?
      define_method(attr_name) do
        @user_info = self.class.read_user_info(taglib, **opts) if @user_info.nil?
        self.class.post_process(@user_info[key], opts)
      end
    end

    def ufid_reader(attr_name, owner, **opts)
      define_method(attr_name) do
        v = self.class.read_ufid(taglib, owner, opts)
        self.class.post_process(v, opts)
      end
    end

    def date_reader(attr_name, **opts)
      opts[:returns] = :datetime unless opts.has_key?(:returns)
      define_method(attr_name) do
        v = self.class.read_date(taglib, opts)
        self.class.post_process(v, opts)
      end
    end

    # gets data from each frame id given only falls back
    # to the id3v1 tag if no id3v2 frames were found
    def read_all_tags(taglib, id3v2_frames, id3v1_tag = nil, **opts)
      frames = []
      id3v2_frames.each { |frame_id| frames += id3v2_frames(taglib, frame_id) }

      data = []
      # only check id3v1 if no id3v2 frames found
      if frames.empty?
        data << id3v1_tag(taglib, id3v1_tag) unless id3v1_tag.nil?
      else
        frames.each { |frame| data << data_from_frame(frame, **opts) }
      end

      data.compact
    end

    def read_first_tag(taglib, id3v2_frames, id3v1_tag = nil, **opts)
      read_all_tags(taglib, id3v2_frames, id3v1_tag, **opts).first
    end

    def read_audio_property(taglib, key)
      taglib.audio_properties.send(key)
    end

    def id3v1_tag(taglib, tag_name)
      return nil if taglib.id3v1_tag.empty?
      v = taglib.id3v1_tag.send(tag_name)
      # TEMPFIX: nonexistent id3v1 tags return an empty string (taglib-ruby issue #49)
      case
      when v.is_a?(Fixnum) && v.zero?
        nil
      when v.is_a?(String) && v.empty?
        nil
      else
        v
      end
    end

    def id3v2_frames(taglib, frame_id)
      taglib.id3v2_tag.frame_list(frame_id)
    end

    def data_from_frame(frame, **opts)
      case
      when frame.is_a?(TagLib::ID3v2::TextIdentificationFrame)
        field_list = frame.field_list
        opts[:field_list] ? field_list : field_list.first
      when frame.is_a?(TagLib::ID3v2::UnsynchronizedLyricsFrame)
        frame.text
      when frame.is_a?(TagLib::ID3v2::CommentsFrame)
        frame.text
      when frame.is_a?(TagLib::ID3v2::AttachedPictureFrame)
        EasyTag::Image.new(frame.picture).tap do |img|
          img.desc = frame.description
          img.type = frame.type
          img.mime_type = frame.mime_type
        end
      else
        nil
      end
    end

    def read_user_info(taglib, **opts)
      user_info = {}
      frame_data = read_all_tags(taglib, ['TXXX'], nil, {field_list: true})

      frame_data.each do |data|
        key = data[0]
        values = data[1..-1]

        user_info[key] = values.count > 1 ? values : values.first
      end

      user_info
    end

    # NOTE: id3v2.3 tags (TYER+TDAT) will lose month/day information due to taglib's
    # internal frame conversion. During the conversion, the TDAT frame is
    # dropped and only the TYER frame is used in the conversion to TDRC.
    # (see: https://github.com/taglib/taglib/issues/127)
    def read_date(taglib, **opts)
      v10_year = taglib.id3v1_tag.year.to_s if taglib.id3v1_tag.year > 0
      v24_date = read_first_tag(taglib, ['TDRC'])

      # check variables in order of importance
      date_str = v24_date || v10_year
      puts "MP3#date: date_str = \"#{date_str}\"" if $DEBUG

      date_str
    end

    def read_ufid(taglib, owner, opts)
      frames = taglib.id3v2_tag.frame_list('UFID')
      frames.each { |frame| return frame.identifier if owner.eql?(frame.owner) }
      nil
    end
  end
end

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
    :type         => Type::STRING,
  },

  # subtitle
  {
    :name         => :subtitle,
    :id3v2_frames => ['TIT3'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # artist
  {
    :name         => :artist,
    :id3v2_frames => ['TPE1'],
    :id3v1_tag    => :artist,
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # artist_sort_order
  #   TSOP - (v2.4 only)
  #   XSOP - Musicbrainz Picard custom
  {
    :name         => :artist_sort_order,
    :id3v2_frames => ['TSOP', 'XSOP'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # album_artist
  {
    :name         => :album_artist,
    :id3v2_frames => ['TPE2'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # album_artist_sort_order
  {
    :name         => :album_artist_sort_order,
    :handler      => :user_info_lookup,
    :handler_opts => {:key => :albumartistsort},
    :type         => Type::STRING,
  },

  # album
  {
    :name         => :album,
    :id3v2_frames => ['TALB'],
    :id3v1_tag    => :album,
    :handler      => :read_first_id3,
    :type         => Type::STRING,
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
    :type         => Type::STRING,
  },
  
  # genre
  {
    :name         => :genre,
    :id3v2_frames => ['TCON'],
    :id3v1_tag    => :genre,
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # disc_subtitle
  {
    :name         => :disc_subtitle,
    :id3v2_frames => ['TSST'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # media
  {
    :name         => :media,
    :id3v2_frames => ['TMED'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # label
  {
    :name         => :label,
    :id3v2_frames => ['TPUB'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # encoded_by
  {
    :name         => :encoded_by,
    :id3v2_frames => ['TENC'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # encoder_settings
  {
    :name         => :encoder_settings,
    :id3v2_frames => ['TSSE'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # group
  {
    :name         => :group,
    :id3v2_frames => ['TIT1'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # composer
  {
    :name         => :composer,
    :id3v2_frames => ['TCOM'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # conductor
  {
    :name         => :conductor,
    :id3v2_frames => ['TPE3'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # remixer
  {
    :name         => :remixer,
    :id3v2_frames => ['TPE4'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # lyrics
  {
    :name         => :lyrics,
    :id3v2_frames => ['USLT'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # lyricist
  {
    :name         => :lyricist,
    :id3v2_frames => ['TEXT'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # copyright
  {
    :name         => :copyright,
    :id3v2_frames => ['TCOP'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
  },

  # bpm
  {
    :name         => :bpm,
    :id3v2_frames => ['TBPM'],
    :handler      => :read_first_id3,
    :type         => Type::INT,
  },

  # mood
  {
    :name         => :mood,
    :id3v2_frames => ['TMOO'],
    :handler      => :read_first_id3,
    :type         => Type::STRING,
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
    :handler      => lambda { |iface| iface.comments.first },
    :type         => Type::STRING,
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

  # apple_id
  {
    :name         => :apple_id,
    :handler      => :read_default,
    :type         => Type::STRING,
  },

  # user_info
  {
    :name         => :user_info,
    :id3v2_frames => ['TXXX'],
    :handler      => :read_field_list_as_key_value,
    :default      => {},
    :options     => {:field_list => true},
  },
  
  # user_info_normalized
  {
    :name         => :user_info_normalized,
    :id3v2_frames => ['TXXX'],
    :handler      => :read_field_list_as_key_value,
    :default      => {},
    :options     => {:normalize => true, 
      :to_sym => true,
      :field_list => true },
  },

  # asin
  {
    :name         => :asin,
    :handler      => :user_info_lookup,
    :handler_opts => {:key => :asin},
    :type         => Type::STRING,
  },

  #
  # MusicBrainz Attributes
  #

  # musicbrainz_track_id
  {
    :name         => :musicbrainz_track_id,
    :handler      => :read_ufid,
    :handler_opts => {:owner => 'http://musicbrainz.org'},
    :type         => Type::STRING,
  },

  # musicbrainz_album_artist_id
  {
    :name         => :musicbrainz_album_artist_id,
    :handler      => :user_info_lookup,
    :handler_opts => {:key => :musicbrainz_album_artist_id},
    :type         => Type::STRING,
  },

  # musicbrainz_artist_id
  {
    :name         => :musicbrainz_artist_id,
    :handler      => :user_info_lookup,
    :handler_opts => {:key => :musicbrainz_artist_id},
    :type         => Type::LIST,
  },
  
  # musicbrainz_album_id
  {
    :name         => :musicbrainz_album_id,
    :handler      => :user_info_lookup,
    :handler_opts => {:key => :musicbrainz_album_id},
    :type         => Type::STRING,
  },
  
  # musicbrainz_album_status
  {
    :name         => :musicbrainz_album_status,
    :handler      => :user_info_lookup,
    :handler_opts => {:key => :musicbrainz_album_status},
    :type         => Type::STRING,
  },
  
  # musicbrainz_album_type
  {
    :name         => :musicbrainz_album_type,
    :handler      => :user_info_lookup,
    :handler_opts => {:key => :musicbrainz_album_type},
    :type         => Type::LIST,
  },

  
  # musicbrainz_release_group_id
  {
    :name         => :musicbrainz_release_group_id,
    :handler      => :user_info_lookup,
    :handler_opts => {:key => :musicbrainz_release_group_id},
    :type         => Type::STRING,
  },
  
  # musicbrainz_album_release_country
  {
    :name         => :musicbrainz_album_release_country,
    :handler      => :user_info_lookup,
    :handler_opts => {:key => :musicbrainz_album_release_country},
    :type         => Type::STRING,
  },

  #
  # Audio Properties
  #
 
  # length 
  {
    :name         => :length,
    :aliases      => [:duration],
    :handler      => :read_audio_property,
    :handler_opts => {:key => :length},
    :type         => Type::INT,
  },

  # bitrate
  {
    :name         => :bitrate,
    :handler      => :read_audio_property,
    :handler_opts => {:key => :bitrate},
    :type         => Type::INT,
  },

  # sample_rate
  {
    :name         => :sample_rate,
    :handler      => :read_audio_property,
    :handler_opts => {:key => :sample_rate},
    :type         => Type::INT,
  },

  # channels
  {
    :name         => :channels,
    :handler      => :read_audio_property,
    :handler_opts => {:key => :channels},
    :type         => Type::INT,
  },

  # copyrighted?
  {
    :name         => :copyrighted?,
    :handler      => :read_audio_property,
    :handler_opts => {:key => :copyrighted?},
    :type         => Type::BOOLEAN,
  },

  # layer
  {
    :name         => :layer,
    :handler      => :read_audio_property,
    :handler_opts => {:key => :layer},
    :type         => Type::INT,
  },

  # original?
  {
    :name         => :original?,
    :handler      => :read_audio_property,
    :handler_opts => {:key => :original?},
    :type         => Type::BOOLEAN,
  },

  # protection_enabled?
  {
    :name         => :protection_enabled?,
    :handler      => :read_audio_property,
    :handler_opts => {:key => :protection_enabled},
    :type         => Type::BOOLEAN,
  },
  ]
end
