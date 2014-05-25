module EasyTag
  class BaseTagger
    attr_reader :taglib

    def year
      date.year unless date.nil?
    end

    def close
      taglib.close
    end

    def method_missing(method, *args, **kwargs)
      warn "#{self.class.name}##{method} does not exist"
      nil
    end
  end

end