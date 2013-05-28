module EasyTag::Attributes
  module Type
    STRING      = 0
    INT         = 1
    FLOAT       = 2
    INT_LIST    = 3
    STRING_LIST = 4
    BOOLEAN     = 5
    DATETIME    = 6
  end
  class BaseAttribute
    # avoid returing empty objects
    def self.obj_or_nil(o)
      if o.class == String
        ret = o.empty? ? nil : o
      else
        o
      end
    end

    def self.name_to_ivar(name)
      name = name.to_s if name.class == Symbol
      name.gsub!(/\?/, '')
      name.insert(0, '@')
      name.to_sym
    end
  end
end
