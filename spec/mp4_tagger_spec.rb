require_relative 'spec_helper'

describe EasyTag::MP4Tagger do
  before(:all) do
    @no_tags = EasyTag::MP4Tagger.new(data_path('no_tags.m4a'))
  end

  after(:all) do
    @no_tags.taglib.close
  end

  context 'when containing no tags' do
    it 'should return the proper response' do
      [:title, :title_sort_order, :artist, :artist_sort_order,
       :album_artist, :album_artist_sort_order, :album, :album_sort_order,
       :genre, :lyrics, :date, :year, :encoded_by, :group, :track_number, :total_tracks,
       :disc_number, :total_discs, :mood, :copyright, :subtitle, :disc_subtitle, :media,
       :label, :composer, :remixer, :lyricist, :asin, :barcode, :catalog_number,
       :musicbrainz_recording_id, :musicbrainz_track_id, :musicbrainz_album_artist_id,
       :musicbrainz_album_id, :musicbrainz_release_group_id,
       :musicbrainz_release_status, :musicbrainz_release_country].each do |attr|
        @no_tags.send(attr).should be(nil), "##{attr} should return nil but didn't"
      end

      [:comments, :album_art, :musicbrainz_artist_id, :musicbrainz_release_type].each do |attr|
        @no_tags.send(attr).should be_a(Array), "##{attr} should be an array but isn't"
        @no_tags.send(attr).empty?.should be(true), "##{attr} should be empty but isn't"
      end
    end
  end
end