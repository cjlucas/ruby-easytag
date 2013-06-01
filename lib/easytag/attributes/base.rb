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
    Utilities = EasyTag::Utilities
    
    attr_reader :name, :aliases, :ivar

    def initialize(args)
      @name    = args[:name]
      @type    = args[:type]
      @default = args[:default] || self.class.default_for_type(@type)
      @options = args[:options] || {}
      @aliases = args[:aliases] || []
      @ivar    = BaseAttribute.name_to_ivar(@name)

      if args[:handler].is_a?(Symbol)
        @handler = method(args[:handler])
      elsif args[:handler].is_a?(Proc)
        @handler = args[:handler]
      end

      # fill default options
      
      # Remove nil objects from array (post process)
      @options[:compact]        ||= false
      # Delete empty objects in array (post process)
      @options[:delete_empty]   ||= false
      # normalizes key (if hash) (handler)
      @options[:normalize]      ||= false
      # cast key (if hash) to symbol (handler)
      @options[:to_sym]         ||= false

    end
    
    def self.can_clone?(obj)
      obj.is_a?(String) || obj.is_a?(Array) || obj.is_a?(Hash)
    end

    def self.deep_copy(obj)
      Marshal.load(Marshal.dump(obj))
    end

    def self.default_for_type(type)
      case type
      when Type::STRING
        ''
      when Type::DATETIME
        nil
      when Type::INT
        0
      when Type::INT_LIST
        [0, 0] # TODO: don't assume an INT_LIST is always an int pair
      when Type::BOOLEAN
        false
      end
    end

    # TODO: this currently doesn't support cloning Strings
    def default
      BaseAttribute.can_clone?(@default) ?
        BaseAttribute.deep_copy(@default) : @default
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
        data = Utilities.get_datetime(data.to_s)
      end
      
      data
    end

    def post_process(data)
      if @options[:is_flag]
        data = data.to_i == 1 ? true : false
      end

      # fall back to default if data is nil
      data ||= default

      # REVIEW: the compact option may not be needed anymore
      #   since we've done away with casting empty strings to nil
      data.compact! if @options[:compact] && data.respond_to?(:compact!)

      if @options[:delete_empty]
        data.select! { |item| !item.empty? if item.respond_to?(:empty?) }
      end

      data
    end
    
    def self.name_to_ivar(name)
      name.to_s.gsub(/\?/, '').insert(0, '@').to_sym
    end
  end
end
