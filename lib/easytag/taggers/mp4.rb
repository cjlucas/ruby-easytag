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
    item_reader :comments, '©cmt', data_type: :string_list, returns: :list
    item_reader :lyrics, '©lyr'
    item_reader :date, '©day', returns: :datetime
    item_reader :encoded_by, '©enc'
    item_reader :encoder_settings, '©too'
    item_reader :group, '©grp'
    item_reader :compilation?, 'cpil', data_type: :bool
    item_reader :bpm, 'tmpo', data_type: :int
    item_reader :mood, 'mood'
    item_reader :copyright, 'cprt'
    item_reader :track_number, 'trkn', data_type: :int_pair, cast: :int_pair, extract_list_pos: 0
    item_reader :total_tracks, 'trkn', data_type: :int_pair, cast: :int_pair, extract_list_pos: 1
    item_reader :disc_number, 'disk', data_type: :int_pair, cast: :int_pair, extract_list_pos: 0
    item_reader :total_discs, 'disk', data_type: :int_pair, cast: :int_pair, extract_list_pos: 1
    item_reader :album_art, 'covr', data_type: :cover_art_list, returns: :list

    item_reader :subtitle, '----:com.apple.iTunes:SUBTITLE'
    item_reader :disc_subtitle, '----:com.apple.iTunes:DISCSUBTITLE'
    item_reader :media, '----:com.apple.iTunes:MEDIA'
    item_reader :label, '----:com.apple.iTunes:LABEL'
    item_reader :composer, '----:com.apple.iTunes:COMPOSER'
    item_reader :remixer, '----:com.apple.iTunes:REMIXER'
    item_reader :conductor, '----:com.apple.iTunes:CONDUCTOR'
    item_reader :lyricist, '----:com.apple.iTunes:LYRICIST'
    item_reader :asin, '----:com.apple.iTunes:ASIN'
    item_reader :isrc, '----:com.apple.iTunes:ISRC'
    item_reader :script, '----:com.apple.iTunes:SCRIPT'
    item_reader :barcode, '----:com.apple.iTunes:BARCODE'
    item_reader :catalog_number, '----:com.apple.iTunes:CATALOGNUMBER'

    item_reader :musicbrainz_recording_id, '----:com.apple.iTunes:MusicBrainz Track Id'
    item_reader :musicbrainz_track_id, '----:com.apple.iTunes:MusicBrainz Release Track Id'
    item_reader :musicbrainz_artist_id, '----:com.apple.iTunes:MusicBrainz Artist Id', data_type: :string_list, returns: :list
    item_reader :musicbrainz_album_artist_id, '----:com.apple.iTunes:MusicBrainz Album Artist Id'
    item_reader :musicbrainz_album_id, '----:com.apple.iTunes:MusicBrainz Album Id'
    item_reader :musicbrainz_disc_id, '----:com.apple.iTunes:MusicBrainz Disc Id'
    item_reader :musicbrainz_trm_id, '----:com.apple.iTunes:MusicBrainz TRM Id'
    item_reader :musicbrainz_release_group_id, '----:com.apple.iTunes:MusicBrainz Release Group Id'
    item_reader :musicbrainz_release_status, '----:com.apple.iTunes:MusicBrainz Album Status'
    item_reader :musicbrainz_release_type, '----:com.apple.iTunes:MusicBrainz Album Type', data_type: :string_list, returns: :list
    item_reader :musicbrainz_release_country, '----:com.apple.iTunes:MusicBrainz Album Release Country'
    item_reader :musicip_puid, '----:com.apple.iTunes:MusicIP PUID'
    item_reader :musicip_fingerprint, '----:com.apple.iTunes:fingerprint'

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