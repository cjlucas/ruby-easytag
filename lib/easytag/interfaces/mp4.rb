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
      :cpil     => 'cpil',
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
      :too      => '©too', # Encoder
      :soaa     => 'soaa', # Sort Order - Album Artist
      :soar     => 'soar', # Sort Order - Track Artist
    }

    def initialize(file)
      @info = TagLib::MP4::File.new(file)
      @tag = @info.tag
    end

    def title
      obj_for_item_key(:nam, ItemType::STRING)
    end

    def artist
      obj_for_item_key(:art, ItemType::STRING)
    end

    def album_artist
      obj_for_item_key(:aart, ItemType::STRING)
    end

    def album
      obj_for_item_key(:alb, ItemType::STRING)
    end

    def genre
      obj_for_item_key(:gen, ItemType::STRING)
    end

    def comments
      obj_for_item_key(:cmt, ItemType::STRING)
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
      covers = obj_for_item_key(:covr, ItemType::COVER_ART_LIST)
      covers.each do |cover|
        @album_art << EasyTag::Image.new(cover.data)
      end

      @album_art
    end

    def apple_id
      obj_for_item_key(:apid, ItemType::STRING)
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
      o = item_to_obj(item, item_type)

      Base.obj_or_nil(o)
    end
  end
end
