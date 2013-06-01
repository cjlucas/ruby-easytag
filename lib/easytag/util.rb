require 'date'

module EasyTag
  module Utilities

    # get_datetime
    #
    # return a DateTime object for a given string
    def self.get_datetime(date_str)
      return nil if date_str.nil?

      # check for known possible formats
      case date_str
      when /^\d{4}$/ # YYYY
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
