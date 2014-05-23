require_relative 'spec_helper'

describe EasyTag::MP3Tagger do
  before(:all) do
    @id3v1_only     = EasyTag::MP3Tagger.new(data_path('only_id3v1.mp3'))
    @id3v2_only     = EasyTag::MP3Tagger.new(data_path('only_id3v2.mp3'))
    @no_tags        = EasyTag::MP3Tagger.new(data_path('no_tags.mp3'))
    @consistency01  = EasyTag::MP3Tagger.new(data_path('consistency.01.mp3'))
    @consistency02  = EasyTag::MP3Tagger.new(data_path('consistency.02.mp3'))
  end

  after(:all) do
    [@id3v1_only, @id3v2_only, @no_tags,
     @consistency01, @consistency02].each { |et| et.taglib.close }
  end

  context 'when containing only id3v1 tags' do
    it 'should read all id3v1 tags correctly' do
      @id3v1_only.title.should        eql('Track Title')
      @id3v1_only.artist.should       eql('Track Artist')
      @id3v1_only.album.should        eql('Album Name')
      @id3v1_only.comments.should     eql(['this is a comment'])
      @id3v1_only.genre.should        eql('Swing')
      @id3v1_only.year.should         be(1988)
      @id3v1_only.date.year.should    be(1988)
      @id3v1_only.track_number.should    be(3)
      @id3v1_only.total_tracks.should be(nil)
      @id3v1_only.disc_number.should     be(nil)
      @id3v1_only.total_discs.should  be(nil)
    end

    it 'should return proper responses for attributes that require id3v2' do
      expect(@id3v1_only.album_art).to be_empty
    end
  end

  context 'when containing only id3v2 tags' do
    it 'should read all id3v2 tags correctly' do
      @id3v2_only.title.should        eql('Track Title')
      @id3v2_only.artist.should       eql('Track Artist')
      @id3v2_only.album.should        eql('Album Name')
      @id3v2_only.comments.should     eql(['this is a comment'])
      @id3v2_only.genre.should        eql('Swing')
      @id3v2_only.year.should         be(1988)
      @id3v2_only.date.year.should    be(1988)
      @id3v2_only.track_number.should    be(3)
      @id3v2_only.total_tracks.should be(nil)
      @id3v2_only.disc_number.should     be(nil)
      @id3v2_only.total_discs.should  be(nil)
    end
  end

  context 'when containing no id3 tags' do
    it 'should return the proper response if a tag does not exist' do
      expect(@no_tags.title).to         be_nil
      expect(@no_tags.artist).to        be_nil
      expect(@no_tags.album).to         be_nil
      expect(@no_tags.album_artist).to  be_nil
      expect(@no_tags.comments).to      be_empty
      expect(@no_tags.genre).to         be_nil
      expect(@no_tags.year).to          be_nil
      expect(@no_tags.date).to          be_nil
      expect(@no_tags.album_art).to     be_empty
      expect(@no_tags.conductor).to     be_nil
      expect(@no_tags.remixer).to       be_nil
      expect(@no_tags.mood).to          be_nil

      @no_tags.track_number.should         be(nil)
      @no_tags.total_tracks.should      be(nil)
      @no_tags.disc_number.should          be(nil)
      @no_tags.total_discs.should       be(nil)
    end

    it 'should return the proper response for musicbrainz data' do
      expect(@no_tags.musicbrainz_album_artist_id).to   be_nil
      expect(@no_tags.musicbrainz_artist_id).to         be_empty
      expect(@no_tags.musicbrainz_release_status).to    be_nil
      expect(@no_tags.musicbrainz_release_group_id).to  be_nil
      expect(@no_tags.musicbrainz_album_id).to          be_nil
      expect(@no_tags.musicbrainz_release_type).to      be_empty
      expect(@no_tags.musicbrainz_track_id).to          be_nil
      expect(@no_tags.musicbrainz_release_country).to   be_nil
    end

    it 'should return the audio properties of the track' do
      @no_tags.length.should      eq(4)
      @no_tags.bitrate.should     eq(74)
      @no_tags.sample_rate.should eq(44100)
      @no_tags.channels.should    eq(2)
      @no_tags.layer.should       eq(3)

      expect(@no_tags.original?).to           be_true
      expect(@no_tags.copyrighted?).to        be_false
      expect(@no_tags.protection_enabled?).to be_false
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
      @consistency01.track_number.should     eql(5)
      @consistency01.total_tracks.should  be(nil)
      @consistency01.disc_number.should      be(3)
      @consistency01.total_discs.should   be(nil)
    end

    it 'should read album art correctly' do
      @consistency01.album_art.count.should be(2)

      art = @consistency01.album_art[0]
      Digest::SHA1.hexdigest(art.data).should eql('6555697ca1bf96117608bfb5a44c05cb622f88eb')
      art.desc.should                         eql('this is the front cover')
      art.type_s.should                       eql('Cover (front)')
      art.mime_type.should                    eql('image/jpeg')
      art.width.should                        eq(10)
      art.height.should                       eq(5)

      art = @consistency01.album_art[1]
      Digest::SHA1.hexdigest(art.data).should eql('9db2996823fb44ed64dfc8f57dc9df3b970c6b22')
      art.desc.should                         eql('this is the artist')
      art.type_s.should                       eql('Other')
      art.mime_type.should                    eql('image/png')
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
      @consistency02.bpm.should                     be(0)
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