require 'easytag'

t = EasyTag::MP3Tagger.new('spec/data/consistency.02.mp3')
#puts t.musicbrainz_album_id
#puts t.instance_variable_get(:@user_info)
puts t.asin
t.taglib.close
