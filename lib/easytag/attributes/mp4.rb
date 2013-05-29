# encoding: UTF-8
require 'easytag/attributes/base'

module EasyTag::Attributes
  # type of TagLib::MP4::Item
  module ItemType
    STRING         = 0 # not part of TagLib::MP4::Item, just for convenience
    STRING_LIST    = 1
    BOOL           = 2
    INT            = 3
    INT_PAIR       = 4
    COVER_ART_LIST = 5
  end

  class MP4Attribute < BaseAttribute
    attr_reader :name, :ivar

    def initialize(args)
      super(args)

      @item_ids = args[:item_ids]
      @item_type = args[:item_type] || ItemType::STRING
    end

    private

    def item_for_id(id, iface)
      iface.info.tag.item_list_map.fetch(id)
    end

    def data_from_item(item)
      case @item_type
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
        artwork = []
        item.to_cover_art_list.each do |img| 
          artwork << EasyTag::Image.new(img.data)
        end
        artwork
      else
        nil
      end
    end

    # read handlers
    
    def read_first_item(iface)
      item = nil
      @item_ids.each do |id|
        item = item_for_id(id, iface) if item.nil?
      end
      
      data_from_item(item) unless item.nil?
    end

  end
end

module EasyTag::Attributes
  MP4_ATTRIB_ARGS = [
  # title
  {
    :name       => :title,
    :item_ids   => ['©nam'],
    :handler    => :read_first_item,
  },

  # album_art
  {
    :name       => :album_art,
    :item_ids   => ['covr'],
    :handler    => :read_first_item,
    :item_type  => ItemType::COVER_ART_LIST,
    :default    => [],
  }
  ]
end
