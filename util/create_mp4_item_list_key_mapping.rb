require 'taglib'

f = TagLib::MP4::File.new(ARGV.shift)

f.tag.item_list_map.to_a.each do |item|
  value = item[0]
  #puts "debug: #{value}"
  key = value.dup.bytes

  # remove junk
  if key.include?(169)
    key.shift
    key.shift
  end

  key = key.pack('c*')
  puts ":#{key.downcase} => '#{value}',"
end
