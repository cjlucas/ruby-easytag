require 'easytag/attributes/mp4'

module EasyTag::Interfaces
  class MP4 < Base
    ATTRIB_ARGS  = EasyTag::Attributes::MP4_ATTRIB_ARGS
    ATTRIB_CLASS = EasyTag::Attributes::MP4Attribute
    
    def initialize(file)
      @info = TagLib::MP4::File.new(file)
    end

    self.build_attributes(ATTRIB_CLASS, ATTRIB_ARGS)
  end
end
