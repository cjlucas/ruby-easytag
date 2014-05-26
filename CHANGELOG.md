##### v0.6.0 (2013-05-25) ####
* complete overhaul, this release is not compatible with any previous release
* FLAC, Ogg support added

##### v0.4.3 (2013-08-20) #####
* fixed: uninitialized constant error with regard to file unsupported exception

##### v0.4.2 (2013-06-23) #####
* added: interal support for `TagLib::ID3v2::UnknownFrame`
* info: because a new version of taglib-ruby hasn't been officially released
  yet, this version of EasyTag requires ref `bb6453e` at `robinst/taglib-ruby`

##### v0.4.1 (2013-06-14) #####
* fixed: `MP4#original_date` now returns it's default value

##### v0.4.0 (2013-06-07) #####
* added: general attributes
  - `#asin`
  - `#conductor`
  - `#remixer`
  - `#mood`
* added: musicbrainz attributes
  - `#musicbrainz_track_id`
  - `#musicbrainz_album_id`
  - `#musicbrainz_album_status`
  - `#musicbrainz_album_type`
  - `#musicbrainz_album_release_country`
  - `#musicbrainz_artist_id`
  - `#musicbrainz_album_artist_id`
  - `#musicbrainz_release_group_id`
* added: audio property attributes
  - `#length` (alias: `#duration`)
  - `#bitrate`
  - `#sample_rate`
  - `#channels`
  - `MP3#layer`
  - `MP3#copyrighted?`
  - `MP3#original?`
  - `MP3#protection_enabled?`
  - `MP4#bits_per_sample`
* added: support for attribute aliases
* changed: attributes that return `String` now default to an empty string
  instead of `nil`
* changed: unsupported attributes now return a default value instead of always
`nil` (ex: `MP3#apple_id`)
* fixed: `#user_info` stores an array of values if item has multiple value
* fixed: improvements to `#date` (issues #1 and #2)

##### v0.3.1 (2013-05-31) #####
* fixed: `MP3#subtitle` now points to correct ID3 frame
* fixed: restored `MP3#user_info`

##### v0.3.0 (2013-05-29) #####
* added:
  - `#encoded_by`
  - `#encoder_settings`
  - `#group`
  - `#composer`
  - `#lyrics`
  - `#compilation?`
  - `#subtitle`
  - `#bpm`
  - `#lyricist`
  - `#copyright`
  - `#comment`
* changed: `#comments` now returns an array, `#comment` is the
  equivalent of the old behavior

##### v0.2.0 (2013-05-25) #####
* added:
  - `#track_num`
  - `#disc_num`
  - `#user_info`
  - `#disc_subtitle`
  - `#media`
  - `#label`
  - `#title_sort_order`
  - `#artist_sort_order`
  - `#album_artist_sort_order`
  - `#album_sort_order`
  - `#original_date`
* fixed: bug related to M4A files without artwork

##### v0.1.0 (2013-05-23) #####
* initial release
