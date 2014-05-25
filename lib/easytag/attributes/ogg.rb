require 'base64'

require_relative 'vorbis'

module EasyTag
  module OggAttributeAccessors
    def field_reader(attr_name, fields = nil, **opts)
      fields = attr_name.to_s.upcase if fields.nil?
      define_method(attr_name) do
        v = self.class.read_fields(taglib.tag, fields, **opts)
        self.class.post_process(v, **opts)
      end
    end

    def album_art_reader(attr_name, **opts)
      opts[:returns] = :list
      define_method(attr_name) do
        v = self.class.read_fields(taglib.tag, 'METADATA_BLOCK_PICTURE', **opts)
        v.collect do |b64_data|
          pic = TagLib::FLAC::Picture.new
          pic.parse(Base64.decode64(b64_data))
          EasyTag::Image.new(pic.data)
        end
      end
    end
  end
end