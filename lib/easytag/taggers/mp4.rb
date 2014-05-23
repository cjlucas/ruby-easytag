require 'easytag/attributes/mp4'

require_relative 'base'

module EasyTag
  class MP4Tagger < BaseTagger
    extend MP4AttributeAccessors

    item_reader :title, '©nam'
    item_reader :title_sort_order, 'sonm'
    item_reader :artist, '©ART'
    item_reader :artist_sort_order, 'soar'
    item_reader :album_artist, 'aART'
    item_reader :album_artist_sort_order, 'soaa'
    item_reader :album, '©alb'
    item_reader :album_sort_order, 'soal'
    item_reader :genre, '©gen'
    item_reader :comments, '©cmt', returns: :string_list
    item_reader :lyrics, '©lyr'
    item_reader :date, '©day', returns: :datetime
    item_reader :encoded_by, '©enc'
    item_reader :encoder_settings, '©too'
    item_reader :group, '©grp'
    item_reader :compilation?, 'cpil', returns: :bool
    item_reader :bpm, 'tmpo', returns: :int
    item_reader :mood, 'mood'
    item_reader :copyright, 'cprt'
    item_reader :track_num, 'trkn', returns: :int_pair
    item_reader :disc_num, 'disk', returns: :int_pair
    item_reader :album_art, 'covr', returns: :cover_art_list

    item_reader :subtitle, '----:com.apple.iTunes:SUBTITLE'
    item_reader :disc_subtitle, '----:com.apple.iTunes:DISCSUBTITLE'
    item_reader :media, '----:com.apple.iTunes:MEDIA'
    item_reader :label, '----:com.apple.iTunes:LABEL'
    item_reader :composer, '----:com.apple.iTunes:COMPOSER'
    item_reader :remixer, '----:com.apple.iTunes:REMIXER'
    item_reader :lyricist, '----:com.apple.iTunes:LYRICIST'
    item_reader :asin, '----:com.apple.iTunes:ASIN'
    item_reader :barcode, '----:com.apple.iTunes:BARCODE'
    item_reader :catalog_number, '----:com.apple.iTunes:CATALOGNUMBER'

    item_reader :musicbrainz_recording_id, '----:com.apple.iTunes:MusicBrainz Track Id'
    item_reader :musicbrainz_track_id, '----:com.apple.iTunes:MusicBrainz Release Track Id'
    item_reader :musicbrainz_artist_id, '----:com.apple.iTunes:MusicBrainz Artist Id', returns: :string_list
    item_reader :musicbrainz_album_artist_id, '----:com.apple.iTunes:MusicBrainz Album Artist Id'
    item_reader :musicbrainz_album_id, '----:com.apple.iTunes:MusicBrainz Album Id'
    item_reader :musicbrainz_release_group_id, '----:com.apple.iTunes:MusicBrainz Release Group Id'
    item_reader :musicbrainz_release_status, '----:com.apple.iTunes:MusicBrainz Album Status'
    item_reader :musicbrainz_release_type, '----:com.apple.iTunes:MusicBrainz Album Type', returns: :string_list
    item_reader :musicbrainz_release_country, '----:com.apple.iTunes:MusicBrainz Album Release Country'

    audio_prop_reader :length
    audio_prop_reader :bitrate
    audio_prop_reader :sample_rate
    audio_prop_reader :channels
    audio_prop_reader :bits_per_sample
    audio_prop_reader :encrypted?

    def initialize(file)
      @taglib = TagLib::MP4::File.new(file)
    end
  end
end