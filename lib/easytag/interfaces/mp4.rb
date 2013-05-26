# encoding: UTF-8

module EasyTag::Interfaces
  class MP4 < Base
    # type of TagLib::MP4::Item
    module ItemType
      STRING         = 0 # not part of TagLib::MP4::Item, just for convenience
      STRING_LIST    = 1
      BOOL           = 2
      INT            = 3
      INT_PAIR       = 4
      COVER_ART_LIST = 5
    end

    ITEM_LIST_KEY_MAP = {
      :aart     => 'aART', # Album Artist
      :akid     => 'akID',
      :apid     => 'apID', # Apple ID
      :atid     => 'atID',
      :cnid     => 'cnID',
      :covr     => 'covr', # Cover Art
      :cpil     => 'cpil', # Compilation
      :cprt     => 'cprt',
      :disk     => 'disk', # Disk [num, total]
      :geid     => 'geID',
      :pgap     => 'pgap',
      :plid     => 'plID',
      :purd     => 'purd', # Purchase Date
      :rtng     => 'rtng',
      :sfid     => 'sfID',
      :stik     => 'stik',
      :trkn     => 'trkn', # Track [num, total]
      :art      => '©ART', # Track Artist
      :alb      => '©alb', # Album
      :cmt      => '©cmt', # Comments
      :day      => '©day', # Release Date
                           # (ex: 2006, 2004-08-10, 2007-11-27T08:00:00Z)
      :gen      => '©gen', # Genre
      :nam      => '©nam', # Title
      :too      => '©too', # Encoding Tool
      :grp      => '©grp', # Grouping
      :lyr      => '©lyr', # Lyrics
      :soaa     => 'soaa', # Sort Order - Album Artist
      :soar     => 'soar', # Sort Order - Track Artist
      :tmpo     => 'tmpo', # BPM
      :cprt     => 'cprt', # Copyright
      :enc      => '©enc', # Encoded by
    }

    def initialize(file)
      @info = TagLib::MP4::File.new(file)
      @tag = @info.tag
    end

    def title
      obj_for_item_key(:nam, ItemType::STRING)
    end

    def title_sort_order
      obj_for_item_key(:sonm, ItemType::STRING)
    end

    def subtitle
      user_info[:subtitle]
    end

    def artist
      obj_for_item_key(:art, ItemType::STRING)
    end

    def artist_sort_order
      obj_for_item_key(:soar, ItemType::STRING)
    end

    def album_artist
      obj_for_item_key(:aart, ItemType::STRING)
    end

    def album_artist_sort_order
      obj_for_item_key(:soaa, ItemType::STRING)
    end

    def album
      obj_for_item_key(:alb, ItemType::STRING)
    end

    def album_sort_order
      obj_for_item_key(:soal, ItemType::STRING)
    end

    def genre
      obj_for_item_key(:gen, ItemType::STRING)
    end

    def comments
      obj_for_item_key(:cmt, ItemType::STRING_LIST) || []
    end

    def comment
      comments.first
    end

    def lyrics
      obj_for_item_key(:lyr, ItemType::STRING)
    end

    # because :day can be anything, including a year, or an exact date,
    # we'll let #date do the parsing, and just grab the year from it
    def year
      date.nil? ? 0 : date.year
    end

    def date
      return @date unless @date.nil?

      date_str = obj_for_item_key(:day, ItemType::STRING)
      @date ||= EasyTag::Utilities.get_datetime(date_str)
    end

    def album_art
      return @album_art unless @album_art.nil?

      @album_art = []
      covers = obj_for_item_key(:covr, ItemType::COVER_ART_LIST) || []
      covers.each do |cover|
        @album_art << EasyTag::Image.new(cover.data)
      end

      @album_art
    end

    def apple_id
      obj_for_item_key(:apid, ItemType::STRING)
    end

    def track_num
      obj_for_item_key(:trkn, ItemType::INT_PAIR) || [0, 0]
    end

    def disc_num
      obj_for_item_key(:disk, ItemType::INT_PAIR) || [0, 0]
    end

    def user_info
      return @user_info unless @user_info.nil?

      @user_info = {}
      @tag.item_list_map.to_a.each do |key, value|
        match_data = key.match(/\:com.apple.iTunes\:(.*)/)
        if match_data
          key = EasyTag::Utilities.normalize_string(match_data[1])
          @user_info[key.to_sym] = value.to_string_list[0]
        end
      end

      @user_info
    end

    def disc_subtitle
      user_info[:discsubtitle]
    end

    def media
      user_info[:media]
    end

    def label
      user_info[:label]
    end

    def encoded_by
      obj_for_item_key(:enc, ItemType::STRING)
    end

    def encoder_settings
      obj_for_frame_id(:too, ItemType::STRING)
    end

    def group
      obj_for_item_key(:grp, ItemType::STRING)
    end

    def composer
      user_info[:composer]
    end

    def compilation?
      obj_for_item_key(:cpil, ItemType::BOOL) || false
    end

    def bpm
      obj_for_item_key(:tmpo, ItemType::INT) || 0
    end

    def lyricist
      user_info[:lyricist]
    end

    def copyright
      obj_for_item_key(:cprt, ItemType::STRING)
    end

    private

    def lookup_item(key)
      item_id = ITEM_LIST_KEY_MAP.fetch(key, nil)
      @tag.item_list_map.fetch(item_id) unless item_id.nil?
    end

    def item_to_obj(item, item_type)
      case item_type
      when ItemType::STRING
        item.to_string_list[0]
      when ItemType::STRING_LIST
        item.to_string_list
      when ItemType::BOOL
        item.to_bool
      when ItemType::INT
        item.to_int
      when ItemType::INT_PAIR
        item.to_int_pair
      when ItemType::COVER_ART_LIST
        item.to_cover_art_list
      else
        nil
      end
    end

    def obj_for_item_key(item_key, item_type)
      return nil if @tag.nil?

      item = lookup_item(item_key)
      o = item_to_obj(item, item_type) unless item.nil?

      Base.obj_or_nil(o)
    end
  end
end
