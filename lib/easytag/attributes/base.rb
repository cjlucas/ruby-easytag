module EasyTag
  module BaseAttributeAccessors

    def audio_prop_reader(attr_name, prop_name = nil, **opts)
      prop_name = attr_name if prop_name.nil?
      define_method(attr_name) do
        v = self.class.read_audio_property(taglib, prop_name)
        self.class.post_process(v, opts)
      end
    end

    def cast(data, key, **opts)
      case opts[key]
      when :int
        data.to_i
      when :int_pair
        Utilities.get_int_pair(data)
      when :datetime
        Utilities.get_datetime(data.to_s)
      when :list
        Array(data)
      when :bool
        [1, '1'].include?(data)
      else
        data
      end
    end

    def extract(data, **opts)
      if opts.has_key?(:extract_list_pos)
        data = data[opts[:extract_list_pos]]
      end
      data
    end

    def post_process(data, opts)
      data = cast(data, :cast, **opts)
      data = extract(data, **opts)
      cast(data, :returns, **opts)
    end

    def read_audio_property(taglib, key)
      taglib.audio_properties.send(key)
    end
  end
end

