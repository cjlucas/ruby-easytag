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

  end
end