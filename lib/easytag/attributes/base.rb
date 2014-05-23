module EasyTag
  module BaseAttributeAccessors

    def audio_prop_reader(attr_name, prop_name = nil, **opts)
      prop_name = attr_name if prop_name.nil?
      define_method(attr_name) do
        v = self.class.read_audio_property(taglib, prop_name)
        self.class.post_process(v, opts)
      end
    end

    def cast(data, opts)
      case opts[:returns]
      when :int
        data.to_i
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

    def post_process(data, opts)
      data = Utilities.get_int_pair(data) if opts[:returns] == :int_pair
      cast(data, opts)
      end

    def read_audio_property(taglib, key)
      taglib.audio_properties.send(key)
    end
  end
end

