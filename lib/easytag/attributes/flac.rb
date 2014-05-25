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
  end
end