require 'date'
require 'easytag'

DOT = '&#x25cf;'
TAGGERS = {
    mp3: EasyTag::MP3Tagger,
    mp4: EasyTag::MP4Tagger,
    flac: EasyTag::FLACTagger,
    ogg: EasyTag::OggTagger
}

NOTES = {
}

methods = Set.new

IGNORED_METHODS = [:method_missing, :taglib, :close]

TAGGERS.each_value do |klass|
  methods.merge(klass.instance_methods - Object.instance_methods - IGNORED_METHODS)
end

puts "#### Standard Attributes (Last Updated: #{Date.today}) ####"
puts '| Method | MP3 | MP4 | FLAC | Ogg | Notes|'
puts '|-------|:---:|:---:|:----:|:---:|------|'

methods.to_a.sort.each do |method|
  line = "| `##{method}` "
  [:mp3, :mp4, :flac, :ogg].each do |key|
    line << (TAGGERS[key].instance_methods.include?(method) ? "| #{DOT} " : '| ')
  end
  line << '|'
  puts line
end
