require 'date'
require 'easytag'

DOT = '&#x25cf;'
TAGGERS = {MP3: EasyTag::MP3Tagger, MP4: EasyTag::MP4Tagger}

NOTES = {
}

methods = Set.new

IGNORED_METHODS = [:method_missing, :close]

TAGGERS.each_value do |klass|
  methods.merge(klass.instance_methods - Object.instance_methods - IGNORED_METHODS)
end

methods = methods.to_a.sort

puts "#### Standard Attributes (Last Updated: #{Date.today}) ####"
puts '| Field | MP3 | MP4 | Notes|'
puts '|-------|:---:|:---:|------|'

methods.each do |method|
  line = "| `##{method}` "
  TAGGERS.each_value do |tagger|
    line << (tagger.instance_methods.include?(method) ? "| #{DOT} " : '| ')
  end
  line << '|'
  puts line
end
