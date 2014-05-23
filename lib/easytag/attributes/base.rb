module EasyTag
  module BaseAttributeAccessors
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
  end
end

