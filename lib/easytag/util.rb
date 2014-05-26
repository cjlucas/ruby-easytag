require 'date'

module EasyTag
  module Utilities
    YEAR_RE   = /(1[89]|20)\d{2}/ # 1800-2099
    MONTH_RE  = /(0[1-9]|1[0-2])/ # 01-12
    DAY_RE    = /(0[1-9]|[12][0-9]|3[01])/ # matches 01-31

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
      when /^#{YEAR_RE}\-#{MONTH_RE}$/ # YYYY-MM
        datetime = DateTime.strptime(date_str, '%Y-%m')
      when /^#{YEAR_RE}#{DAY_RE}#{MONTH_RE}$/ # YYYYDDMM (TYER+TDAT)
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
    # Parses a pos/total string and returns a pair of ints (or nils)
    def self.get_int_pair(input)
      return input.collect { |i| i.to_i }[0..1] if input.is_a?(Array)

      input = input.to_s
      pair = [0, 0]

      unless input.nil? || input.empty?
        if input.include?('/')
          pair = input.split('/').collect { |it| it.to_i }
        else
          pair[0] = input.to_i
        end
      end

      pair
    end
  end
end
