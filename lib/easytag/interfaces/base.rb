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

      def close
        @info.close
      end

      def self.build_attributes(attrib_class, attrib_args)
        attrib_args.each do |attrib_args|
          attrib = attrib_class.new(attrib_args)
          define_method(attrib.name) do
            instance_variable_get(attrib.ivar) || 
              instance_variable_set(attrib.ivar, attrib.call(self))
          end

          attrib.aliases.each { |a| alias_method a, attrib.name}
        end
      end

    end
  end
end
