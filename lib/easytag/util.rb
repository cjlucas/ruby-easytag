require 'date'

module EasyTag
  module Utilities
    YEAR_RE = /(1[89]|20)\d{2}/ # 1800-2099

    # get_datetime
    #
    # return a DateTime object for a given string
    def self.get_datetime(date_str)
      return nil if date_str.nil?

      # DateTime can't handle 00, so replace days/months that are 00 with 01
      #   (currently only works with YYYY-MM-DD)
      until date_str[/\-(00)\-?/].nil?
        date_str[/\-(00)\-?/, 1] = '01'
      end

      # check for known possible formats
      case date_str
      when /^#{YEAR_RE}$/
        datetime = DateTime.strptime(date_str, '%Y')
      when /^\d{4}\-\d{2}$/ # YYYY-MM
        datetime = DateTime.strptime(date_str, '%Y-%m')
      when /^\d{4}[0-3]\d[0-1]\d$/ # YYYYDDMM (TYER+TDAT)
        datetime = DateTime.strptime(date_str, '%Y%d%m')
      else
        datetime = nil
      end

      # let DateTime try to parse the stored date as a last resort
      if datetime.nil?
        begin
          datetime = DateTime.parse(date_str)
        rescue ArgumentError
          warn "DateTime couldn't parse '#{date_str}'"
        end
      end

      # try to get the year at the least (don't attempt if date_str is a year)
      if datetime.nil? && !date_str.match(YEAR_RE).to_s.eql?(date_str)
        warn 'Falling back to year-only parsing'
        datetime = get_datetime(date_str.match(YEAR_RE).to_s)
      end

      datetime
    end

    # get_int_pair
    #
    # Parses a pos/total string and returns a pair of ints
    def self.get_int_pair(str)
      pair = [0, 0]

      unless str.nil? || str.empty?
        if str.include?('/')
          pair = str.split('/').map { |it| it.to_i }
        else
          pair[0] = str.to_i
        end
      end

      pair
    end

    def self.normalize_string(str)
      str = str.to_s
      # downcase string
      str.downcase!
      # we want snakecase
      str.gsub!(/\s/, '_')
      # we only want alphanumeric characters
      str.gsub(/\W/, '')
    end

    def self.normalize_object(object)
      if object.is_a?(String)
        normalize_string(object)
      elsif object.is_a?(Symbol)
        normalize_string(object.to_s).to_sym
      elsif object.is_a?(Array)
        new_array = []
        object.each { |item| new_array << normalize_object(item) }
        new_array
      else
          object
      end
    end

  end
end
