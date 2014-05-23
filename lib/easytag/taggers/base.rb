module EasyTag
  class BaseTagger
    attr_reader :taglib

    def year
      date.year unless date.nil?
    end

    def close
      taglib.close
    end
  end
end