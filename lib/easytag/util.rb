require 'date'

module EasyTag
  module Utilities

    # get_datetime
    #
    # return a DateTime object for a given string
    def self.get_datetime(date_str)
      return nil if date_str.nil?

      datetime = nil
      # let DateTime try to parse the stored date
      begin
        datetime = DateTime.parse(date_str)
      rescue ArgumentError
        warn "DateTime couldn't parse '#{date_str}'"
      end

      # now we can try to parse it
      if datetime.nil?
        if date_str.match(/\d{4}/) # YYYY
          datetime = DateTime.strptime(date_str, '%Y')
        elsif date_str.match(/\d{4}\-\d{2}/) # YYYY-MM
          datetime = DateTime.strptime(date_str, '%Y-%m')
        end
      end

      datetime
    end

  end
end
