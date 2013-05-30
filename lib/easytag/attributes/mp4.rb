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

    def read_user_info(iface)
      kv_hash = {}
      iface.info.tag.item_list_map.to_a.each do |key, value|
        match_data = key.match(/\:com.apple.iTunes\:(.*)/)
        if match_data
          key = match_data[1]
          key = Utilities.normalize_string(key) if @options[:normalize]
          key = key.to_sym if @options[:to_sym]
          kv_hash[key] = value.to_string_list[0]
        end
      end

      kv_hash
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

  # title_sort_order
  {
    :name       => :title_sort_order,
    :item_ids   => ['sonm'],
    :handler    => :read_first_item,
  },

  # artist
  {
    :name       => :artist,
    :item_ids   => ['©ART'],
    :handler    => :read_first_item,
  },

  # artist_sort_order
  {
    :name       => :artist_sort_order,
    :item_ids   => ['soar'],
    :handler    => :read_first_item,
  },

  # album_artist
  {
    :name       => :album_artist,
    :item_ids   => ['aART'],
    :handler    => :read_first_item,
  },

  # album_artist_sort_order
  {
    :name       => :album_artist_sort_order,
    :item_ids   => ['soaa'],
    :handler    => :read_first_item,
  },

  # album
  {
    :name       => :album,
    :item_ids   => ['©alb'],
    :handler    => :read_first_item,
  },

  # album_sort_order
  {
    :name       => :album_sort_order,
    :item_ids   => ['soal'],
    :handler    => :read_first_item,
  },

  # genre
  {
    :name       => :genre,
    :item_ids   => ['©gen'],
    :handler    => :read_first_item,
  },

  # comments
  {
    :name       => :comments,
    :item_ids   => ['©cmt'],
    :handler    => :read_first_item,
    :item_type  => ItemType::STRING_LIST,
    :default    => [],
  },

  # comment
  {
    :name       => :comment,
    :handler    => lambda { |iface| iface.comments.first }
  },

  # lyrics
  {
    :name       => :lyrics,
    :item_ids   => ['©lyr'],
    :handler    => :read_first_item,
  },

  # date
  {
    :name       => :date,
    :item_ids   => ['©day'],
    :handler    => :read_first_item,
    :type       => Type::DATETIME,
  },

  # year
  {
    :name         => :year,
    :handler      => lambda { |iface| iface.date.nil? ? 0 : iface.date.year }
  },

  # apple_id
  {
    :name       => :apple_id,
    :item_ids   => ['apid'],
    :handler    => :read_first_item,
  },

  # encoded_by
  {
    :name       => :encoded_by,
    :item_ids   => ['©enc'],
    :handler    => :read_first_item,
  },

  # encoder_settings
  {
    :name       => :encoder_settings,
    :item_ids   => ['©too'],
    :handler    => :read_first_item,
  },

  # group
  {
    :name       => :group,
    :item_ids   => ['©grp'],
    :handler    => :read_first_item,
  },

  # compilation?
  {
    :name       => :compilation?,
    :item_ids   => ['cpil'],
    :handler    => :read_first_item,
    :item_type  => ItemType::BOOL,
    :default    => false,
  },

  # bpm
  {
    :name       => :bpm,
    :item_ids   => ['tmpo'],
    :handler    => :read_first_item,
    :item_type  => ItemType::INT,
    :default    => 0,
  },

  # copyright
  {
    :name       => :copyright,
    :item_ids   => ['cprt'],
    :handler    => :read_first_item,
  },

  # track_num
  {
    :name       => :track_num,
    :item_ids   => ['trkn'],
    :handler    => :read_first_item,
    :item_type  => ItemType::INT_PAIR,
    :default    => [0, 0],
  },

  # disc_num
  {
    :name       => :disc_num,
    :item_ids   => ['disk'],
    :handler    => :read_first_item,
    :item_type  => ItemType::INT_PAIR,
    :default    => [0, 0],
  },

  # album_art
  {
    :name       => :album_art,
    :item_ids   => ['covr'],
    :handler    => :read_first_item,
    :item_type  => ItemType::COVER_ART_LIST,
    :default    => [],
  },

  # user_info
  {
    :name       => :user_info,
    :handler    => :read_user_info,
    :default    => {},
    :options    => {:normalize => true, :to_sym => true},
  },

  # subtitle
  {
    :name       => :subtitle,
    :handler    => lambda { |iface| iface.user_info[:subtitle] }
  },

  # disc_subtitle
  {
    :name       => :disc_subtitle,
    :handler    => lambda { |iface| iface.user_info[:discsubtitle] }
  },

  # media
  {
    :name       => :media,
    :handler    => lambda { |iface| iface.user_info[:media] }
  },

  # label
  {
    :name       => :label,
    :handler    => lambda { |iface| iface.user_info[:label] }
  },

  # composer
  {
    :name       => :composer,
    :handler    => lambda { |iface| iface.user_info[:composer] }
  },

  # lyricist
  {
    :name       => :lyricist,
    :handler    => lambda { |iface| iface.user_info[:lyricist] }
  },

  ]
end
