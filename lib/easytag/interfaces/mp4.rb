# encoding: UTF-8

require 'easytag/attributes/mp4'

module EasyTag::Interfaces
  class MP4 < Base
    def initialize(file)
      @info = TagLib::MP4::File.new(file)
    end

    EasyTag::Attributes::MP4_ATTRIB_ARGS.each do |attrib_args|
      attrib = EasyTag::Attributes::MP4Attribute.new(attrib_args)
      define_method(attrib.name) do
        instance_variable_get(attrib.ivar) || 
          instance_variable_set(attrib.ivar, attrib.call(self))
      end
    end

  end
end
