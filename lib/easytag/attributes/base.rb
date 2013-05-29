module EasyTag::Attributes
  # for type casting
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
    def initialize(args)
      @name = args[:name]
      @default = args[:default]
      @type = args[:type] || Type::STRING
      @options = args[:options] || {}
      @ivar = BaseAttribute.name_to_ivar(@name)

      if args[:handler].is_a?(Symbol)
        @handler = method(args[:handler])
      elsif args[:handler].is_a?(Proc)
        @handler = args[:handler]
      end

      # fill default options
      
      # Remove nil objects from array (post process)
      @options[:compact]    ||= false
      # normalizes key (if hash) (handler)
      @options[:normalize]  ||= false
      # cast key (if hash) to symbol (handler)
      @options[:to_sym]     ||= false

    end
    
    def call(iface)
      #puts 'entered call()'
      data = @handler.call(iface)
      data = type_cast(data)
      post_process(data)
    end

    def type_cast(data)
      case @type
      when Type::INT
        data = data.to_i
      when Type::DATETIME
        data = EasyTag::Utilities.get_datetime(data.to_s)
      end
      
      data
    end

    def post_process(data)
      if @options[:is_flag]
        data = data.to_i == 1 ? true : false
      end

      # fall back to default if data is nil
      data = BaseAttribute.obj_or_nil(data)
      data = @default.dup if data.nil? unless @default.nil?

      # run obj_or_nil on each item in array
      data.map! { |item| BaseAttribute.obj_or_nil(item) } if data.is_a?(Array)

      if @options[:compact] && data.respond_to?(:compact!)
        data.compact!
      end

      data
    end
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
