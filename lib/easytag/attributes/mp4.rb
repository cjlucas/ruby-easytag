# encoding: UTF-8
require 'easytag/attributes/base'

module EasyTag
  module MP4AttributeAccessors
    include BaseAttributeAccessors

    def item_reader(attr_name, key = nil, **opts)
      key = attr_name if key.nil?

      define_method(attr_name) do
        v = self.class.read_item(taglib, key, **opts)
        self.class.post_process(v, **opts)
      end
    end

    def data_from_item(item, **opts)
      case opts[:returns]
      when :list
        item.to_string_list
      when :bool
        item.to_bool
      when :int
        item.to_int
      when :int_pair
        item.to_int_pair
      when :cover_art_list
        item.to_cover_art_list.collect { |img| EasyTag::Image.new(img.data) }
      else
        item.to_string_list[0]
      end
    end

    def read_item(taglib, key, **opts)
      item = taglib.tag.item_list_map[key]
      data_from_item(item, **opts) unless item.nil?
    end
  end
end

