# encoding: UTF-8

module EasyTag::Interfaces
  class MP4 < Base
    # type of TagLib::MP4::Item
    module ItemType
      STRING      = 0
      STRING_LIST = 1
      BOOL        = 2
      INT         = 3
      INT_PAIR    = 4
    end

    ITEM_LIST_KEY_MAP = {
      :itunmovi => '----:com.apple.iTunes:iTunMOVI',
      :itunnorm => '----:com.apple.iTunes:iTunNORM',
      :itunsmpb => '----:com.apple.iTunes:iTunSMPB',
      :aart     => 'aART',
      :akid     => 'akID',
      :apid     => 'apID',
      :atid     => 'atID',
      :cnid     => 'cnID',
      :covr     => 'covr',
      :cpil     => 'cpil',
      :cprt     => 'cprt',
      :disk     => 'disk',
      :geid     => 'geID',
      :pgap     => 'pgap',
      :plid     => 'plID',
      :purd     => 'purd',
      :rtng     => 'rtng',
      :sfid     => 'sfID',
      :stik     => 'stik',
      :trkn     => 'trkn',
      :art      => '©ART',
      :alb      => '©alb',
      :cmt      => '©cmt',
      :day      => '©day',
      :gen      => '©gen',
      :nam      => '©nam',
      :too      => '©too',
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

    def year
      return @year unless @year.nil?

      # taglib returns the year as a string, we want an int
      o = obj_for_item_key(:day, ItemType::STRING)
      @year = o.to_i unless o.nil?
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
