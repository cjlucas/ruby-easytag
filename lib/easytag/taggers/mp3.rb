require 'easytag/attributes/mp3'

require_relative 'base'

module EasyTag
  class MP3Tagger < BaseTagger
    extend MP3AttributeAccessors

    single_tag_reader :title, 'TIT2', :title
    single_tag_reader :title_sort_order, %w{TSOT XSOT}
    single_tag_reader :subtitle, 'TIT3'
    single_tag_reader :artist, 'TPE1', :artist
    single_tag_reader :artist_sort_order, %w{TSOP XSOP}
    single_tag_reader :album, 'TALB', :album
    single_tag_reader :album_sort_order, %w{TSOA XSOA}
    single_tag_reader :album_artist, 'TPE2'
    single_tag_reader :album_artist_sort_order, 'TSO2'
    single_tag_reader :compilation?, 'TCMP', nil, returns: :bool
    single_tag_reader :genre, 'TCON', :genre
    single_tag_reader :disc_subtitle, 'TSST'
    single_tag_reader :media, 'TMED'
    single_tag_reader :label, 'TPUB'
    single_tag_reader :encoded_by, 'TENC'
    single_tag_reader :encoder_settings, 'TSSE'
    single_tag_reader :group, 'TIT1'
    single_tag_reader :composer, 'TCOM'
    single_tag_reader :conductor, 'TPE3'
    single_tag_reader :remixer, 'TPE4'
    single_tag_reader :lyrics, 'USLT'
    single_tag_reader :lyricist, 'TEXT'
    single_tag_reader :copyright, 'TCOP'
    single_tag_reader :bpm, 'TBPM', nil, returns: :int
    single_tag_reader :mood, 'TMOD'
    single_tag_reader :isrc, 'TSRC'
    single_tag_reader :track_number, 'TRCK', :track, cast: :int_pair, extract_list_pos: 0
    single_tag_reader :total_tracks, 'TRCK', :track, cast: :int_pair, extract_list_pos: 1
    single_tag_reader :disc_number, 'TPOS', nil, cast: :int_pair, extract_list_pos: 0
    single_tag_reader :total_discs, 'TPOS', nil, cast: :int_pair, extract_list_pos: 1
    single_tag_reader :original_date, %w{TDOR TORY}, nil, returns: :datetime

    all_tags_reader :comments, 'COMM', :comment
    all_tags_reader :album_art, 'APIC'

    audio_prop_reader :length
    audio_prop_reader :bitrate
    audio_prop_reader :sample_rate
    audio_prop_reader :channels
    audio_prop_reader :copyrighted?
    audio_prop_reader :layer
    audio_prop_reader :original?
    audio_prop_reader :protection_enabled?, :protection_enabled

    user_info_reader :asin, 'ASIN'
    user_info_reader :script, 'SCRIPT'
    user_info_reader :barcode, 'BARCODE'
    user_info_reader :catalog_number, 'CATALOGNUMBER'
    user_info_reader :musicbrainz_track_id, 'MusicBrainz Release Track Id'
    user_info_reader :musicbrainz_album_id, 'MusicBrainz Album Id'
    user_info_reader :musicbrainz_artist_id, 'MusicBrainz Artist Id', returns: :list
    user_info_reader :musicbrainz_album_artist_id, 'MusicBrainz Album Artist Id'
    user_info_reader :musicbrainz_trm_id, 'MusicBrainz TRM Id'
    user_info_reader :musicbrainz_disc_id, 'MusicBrainz Disc Id'
    user_info_reader :musicbrainz_release_status, 'MusicBrainz Album Status'
    user_info_reader :musicbrainz_release_type, 'MusicBrainz Album Type', returns: :list
    user_info_reader :musicbrainz_release_country, 'MusicBrainz Album Release Country'
    user_info_reader :musicbrainz_release_group_id, 'MusicBrainz Release Group Id'
    user_info_reader :musicip_puid, 'MusicIP PUID'
    user_info_reader :musicip_fingerprint, 'MusicMagic Fingerprint'

    ufid_reader :musicbrainz_recording_id, 'http://musicbrainz.org'
    date_reader :date

    def initialize(file)
      @taglib = TagLib::MPEG::File.new(file)
    end
  end
end
