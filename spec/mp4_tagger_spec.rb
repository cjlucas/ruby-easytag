require_relative 'spec_helper'

describe EasyTag::MP4Tagger do
  before(:all) do
    @no_tags        = EasyTag::MP4Tagger.new(data_path('no_tags.m4a'))
    @consistency01  = EasyTag::MP4Tagger.new(data_path('consistency.01.m4a'))
    @consistency02  = EasyTag::MP4Tagger.new(data_path('consistency.02.m4a'))
  end

  after(:all) do
    [@no_tags, @consistency01, @consistency02].each { |et| et.close }
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

  context 'when containing image data' do
    it 'should read all attributes correctly' do
      @consistency01.title.should         eql('Track Title')
      @consistency01.artist.should        eql('Artist Name Here')
      @consistency01.album_artist.should  eql('Album Artist Here')
      @consistency01.album.should         eql('Album Name Here')
      @consistency01.comments.should      eql(['This is my comment.'])
      @consistency01.genre.should         eql('Polka')
      @consistency01.year.should          eql(1941)
      @consistency01.date.year.should     eql(1941)
      @consistency01.date.month.should    eql(12)
      @consistency01.date.day.should      eql(7)
      @consistency01.track_number.should  eql(5)
      @consistency01.total_tracks.should  be(0)
      @consistency01.disc_number.should   be(3)
      @consistency01.total_discs.should   be(0)
    end

    it 'should read album art correctly' do
      @consistency01.album_art.count.should be(1)

      art = @consistency01.album_art[0]
      Digest::SHA1.hexdigest(art.data).should eql('6555697ca1bf96117608bfb5a44c05cb622f88eb')
      art.mime_type.should                    eql('image/jpeg')
      art.width.should                        eq(10)
      art.height.should                       eq(5)
    end
  end

  context 'when containing musicbrainz data' do
    it 'should read all attributes correctly' do
      @consistency02.title.should                   eql('She Lives in My Lap')
      @consistency02.title_sort_order.should        be(nil)
      @consistency02.artist.should                  eql('OutKast feat. Rosario Dawson')
      @consistency02.artist_sort_order.should       eql('OutKast feat. Dawson, Rosario')
      @consistency02.album_artist.should            eql('OutKast')
      @consistency02.album_artist_sort_order.should eql('OutKast')
      @consistency02.album.should                   eql('Speakerboxxx / The Love Below')
      @consistency02.album_sort_order.should        be(nil)
      @consistency02.comments.count.should          be(0)
      @consistency02.genre.should                   be(nil)
      @consistency02.year.should                    be(2003)
      @consistency02.date.year.should               be(2003)
      @consistency02.date.month.should              be(9)
      @consistency02.date.day.should                be(23)
      @consistency02.track_number.should            be(8)
      @consistency02.total_tracks.should            be(21)
      @consistency02.disc_number.should                be(2)
      @consistency02.total_discs.should             be(2)
      @consistency02.disc_subtitle.should           eql('The Love Below')
      @consistency02.media.should                   eql('CD')
      @consistency02.label.should                   eql('Arista')
      @consistency02.compilation?.should            be(true)
      @consistency02.bpm.should                     be(nil)
    end

    it 'should read all musicbrainz attributes correctly' do
      @consistency02.asin.should                          eql('B0000AGWFX')
      @consistency02.script.should                        eql('Latn')
      @consistency02.barcode.should                       eql('828765013321')
      @consistency02.catalog_number.should                eql('82876 50133 2')
      @consistency02.musicbrainz_release_type.should      eql(['album'])
      @consistency02.musicbrainz_album_artist_id.should   eql('73fdb566-a9b1-494c-9f32-51768ec9fd27')
      @consistency02.musicbrainz_artist_id.count.should   be(2)
      @consistency02.musicbrainz_artist_id.should         include('73fdb566-a9b1-494c-9f32-51768ec9fd27')
      @consistency02.musicbrainz_artist_id.should         include('9facf8dc-df23-4561-85c5-ece75d692f21')
      @consistency02.musicbrainz_album_id.should          eql('468cd19e-d55c-46a2-a5a6-66292d2f0a90')
      @consistency02.musicbrainz_release_group_id.should  eql('fa64febd-61e0-346e-aaa2-04564ed4f0a3')
      @consistency02.musicbrainz_release_country.should   eql('US')
      @consistency02.musicbrainz_release_status.should    eql('official')
    end
  end
end