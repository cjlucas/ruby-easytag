require 'easytag/attributes/vorbis'

require_relative 'base'

module EasyTag
  module VorbisAttributes
    include VorbisAttributeAccessors

    def initialize_vorbis_attributes
      field_reader :title
      field_reader :title_sort_order, 'TITLESORT'
      field_reader :subtitle
      field_reader :artist
      field_reader :artist_sort_order, 'ARTISTSORT'
      field_reader :album
      field_reader :album_sort_order, 'ALBUMSORT'
      field_reader :album_artist, 'ALBUMARTIST'
      field_reader :album_artist_sort_order, 'ALBUMARTISTSORT'
      field_reader :compilation?, 'COMPILATION', returns: :bool
      field_reader :genre
      field_reader :disc_subtitle, 'DISCSUBTITLE'
      field_reader :media
      field_reader :label
      field_reader :encoded_by, 'ENCODEDBY'
      field_reader :encoder_settings, 'ENCODERSETTINGS'
      field_reader :group
      field_reader :composer
      field_reader :conductor
      field_reader :remixer
      field_reader :lyrics
      field_reader :lyricist
      field_reader :copyright
      field_reader :bpm, returns: :int
      field_reader :mood
      field_reader :isrc
      field_reader :track_number, 'TRACKNUMBER', returns: :int
      field_reader :total_tracks, %w{TRACKTOTAL TOTALTRACKS}, returns: :int
      field_reader :disc_number, 'DISCNUMBER', returns: :int
      field_reader :total_discs, %W{DISCTOTAL TOTALDISCS}, returns: :int
      field_reader :date, returns: :datetime
      field_reader :original_date, 'ORIGINALDATE', returns: :datetime
      field_reader :comments, 'COMMENT', returns: :list

      album_art_reader :album_art

      field_reader :asin, 'ASIN'
      field_reader :script, 'SCRIPT'
      field_reader :barcode, 'BARCODE'
      field_reader :catalog_number, 'CATALOGNUMBER'
      field_reader :musicbrainz_recording_id, 'MUSICBRAINZ_TRACKID'
      field_reader :musicbrainz_track_id, 'MUSICBRAINZ_RELEASETRACKID'
      field_reader :musicbrainz_album_id, 'MUSICBRAINZ_ALBUMID'
      field_reader :musicbrainz_artist_id, 'MUSICBRAINZ_ARTISTID', returns: :list
      field_reader :musicbrainz_album_artist_id, 'MUSICBRAINZ_ALBUMARTISTID'
      field_reader :musicbrainz_trm_id, 'MUSICBRAINZ_TRMID'
      field_reader :musicbrainz_disc_id, 'MUSICBRAINZ_DISCID'
      field_reader :musicbrainz_release_status, 'RELEASESTATUS'
      field_reader :musicbrainz_release_type, 'RELEASETYPE', returns: :list
      field_reader :musicbrainz_release_country, 'RELEASECOUNTRY'
      field_reader :musicbrainz_release_group_id, 'MUSICBRAINZ_RELEASEGROUPID'
      field_reader :musicip_puid, 'MUSICIP_PUID'
      # TODO
      # field_reader :musicip_fingerprint, 'MusicMagic Fingerprint'
    end
  end
end