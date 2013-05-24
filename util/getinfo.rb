require_relative '../lib/audiometadata'

ARGV.each do |arg|
  a = AudioMetadata::Proxy.new(arg)
  (AudioMetadata::Proxy.instance_methods - Object.instance_methods).each do |m|
    out = a.send(m)
    puts out.to_s.length < 500 ? "#{m}: #{out}" : "#{m}: <data>"
  end
    puts
    puts
end

