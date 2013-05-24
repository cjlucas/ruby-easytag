require 'easytag/image'
require 'easytag/interfaces/base'
require 'easytag/interfaces/mp3'
require 'easytag/interfaces/mp4'

module EasyTag::Interfaces
  # get all audio interfaces
  def self.all
    # get all classes in Interfaces
    classes = self.constants.map do |sym|
      const = self.const_get(sym)
      const if const.class == Class && const.method_defined?(:info)
    end

    # filter out nil's
    classes.compact
  end
end
