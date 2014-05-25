require_relative 'vorbis'

module EasyTag
  module FLACAttributeAccessors
    def field_reader(attr_name, fields = nil, **opts)
      fields = attr_name.to_s.upcase if fields.nil?
      define_method(attr_name) do
        v = self.class.read_fields(taglib.xiph_comment, fields, **opts)
        self.class.post_process(v, **opts)
      end
    end

    def album_art_reader(attr_name, **opts)
      define_method(attr_name) do
        taglib.picture_list.collect do |pic|
          EasyTag::Image.new(pic.data).tap do |img|
            img.mime_type = pic.mime_type
            img.type      = pic.type
          end
        end
      end
    end

  end
end