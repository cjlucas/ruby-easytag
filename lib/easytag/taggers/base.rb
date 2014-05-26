module EasyTag
  class BaseTagger
    attr_reader :taglib

    def year
      date.nil? ? 0 : date.year
    end

    def close
      taglib.close
    end

    def method_missing(method, *args, **kwargs)
      warn "#{self.class.name}##{method} does not exist"
      method.to_s[-1].eql?('?') ? false : nil
    end
  end

end