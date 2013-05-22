module EasyTag
  module Interfaces
    class Base
      attr_reader :info
      # avoid returing empty objects
      def self.obj_or_nil(o)
        if o.class == String
          ret = o.empty? ? nil : o
        else
          o
        end
      end

    end
  end
end
