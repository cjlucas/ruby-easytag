require 'taglib'

require 'easytag/interfaces'

module EasyTag
  class Base
    attr_reader :interface

    def self.build_proxy_methods(iface)
      # generate dynamic getters
      (iface.instance_methods - Object.instance_methods).each do |m|
        define_method(m) { proxy_getter(m) }
      end
    end

    def proxy_getter(m)
      unless @interface.respond_to?(m)
        warn "#{@interface.class} doesn't support method #{m}"
      end
      
      @interface.send(m)
    end

    # dynamic instance method generation
    EasyTag::Interfaces.all.each { |iface| self.build_proxy_methods(iface) }
  end
end

