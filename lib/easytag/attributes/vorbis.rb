require_relative 'base'

module EasyTag
  module VorbisAttributeAccessors
    include BaseAttributeAccessors

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

    def read_fields(xiph_comment, fields, **opts)
      fields = Array(fields)
      fields.each do |field|
        next unless xiph_comment.contains?(field)
        data = xiph_comment.field_list_map[field]
        return opts[:returns] == :list ? data : data.first
      end
      nil
    end
  end
end