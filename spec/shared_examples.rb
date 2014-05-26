shared_context 'no tags' do |tagger|
  after(:all) do
    tagger.close
  end

  it 'non-list attributes should return nil' do
    [:title, :title_sort_order, :artist, :artist_sort_order,
     :album_artist, :album_artist_sort_order, :album, :album_sort_order,
     :genre, :lyrics, :date, :year, :encoded_by, :group, :track_number, :total_tracks,
     :disc_number, :total_discs, :mood, :copyright, :subtitle, :disc_subtitle, :media,
     :label, :composer, :remixer, :lyricist, :asin, :barcode, :catalog_number,
     :musicbrainz_recording_id, :musicbrainz_track_id, :musicbrainz_album_artist_id,
     :musicbrainz_album_id, :musicbrainz_release_group_id,
     :musicbrainz_release_status, :musicbrainz_release_country].each do |attr|
      actual = tagger.send(attr)
      actual.should be(nil), "##{attr} should return nil but returned #{actual.class}:#{actual}\""
    end
  end

  it 'list attributes should be empty' do
    [:comments, :album_art, :musicbrainz_artist_id, :musicbrainz_release_type].each do |attr|
      actual = tagger.send(attr)
      actual.should be_a(Array), "##{attr} should return an Array but returned #{actual.class}"
      actual.empty?.should be(true), "##{attr} should be empty but isn't"
    end
  end
end

shared_context 'consistency' do |tagger|
  after(:all) do
    tagger.close
  end

  it 'should return all standard attributes consistently' do
    tagger.title.should                   eql('She Lives in My Lap')
    tagger.title_sort_order.should        be(nil)
    tagger.artist.should                  eql('OutKast feat. Rosario Dawson')
    tagger.artist_sort_order.should       eql('OutKast feat. Dawson, Rosario')
    tagger.album_artist.should            eql('OutKast')
    tagger.album_artist_sort_order.should eql('OutKast')
    tagger.album.should                   eql('Speakerboxxx / The Love Below')
    tagger.album_sort_order.should        be(nil)
    tagger.comments.count.should          be(0)
    tagger.genre.should                   be(nil)
    tagger.year.should                    be(2003)
    tagger.date.year.should               be(2003)
    tagger.date.month.should              be(9)
    tagger.date.day.should                be(23)
    tagger.track_number.should            be(8)
    tagger.total_tracks.should            be(21)
    tagger.disc_number.should             be(2)
    tagger.total_discs.should             be(2)
    tagger.disc_subtitle.should           eql('The Love Below')
    tagger.media.should                   eql('CD')
    tagger.label.should                   eql('Arista')
    tagger.compilation?.should            be(true)
    tagger.bpm.should                     be(nil)
    tagger.asin.should                    eql('B0000AGWFX')
    tagger.isrc.should                    eql('USAR10300997')
    tagger.script.should                  eql('Latn')
    tagger.barcode.should                 eql('828765013321')
    tagger.catalog_number.should          eql('82876 50133 2')
  end

  it 'should return consistent album art' do
    tagger.album_art.count.should be(1)

    art = tagger.album_art[0]
    Digest::SHA1.hexdigest(art.data).should eql('de2e3998753d4a11241205788b5c6fe4bf9dc722')
    art.mime_type.should                    eql('image/jpeg')
    art.width.should                        eq(500)
    art.height.should                       eq(500)
  end

  it 'should return musicbrainz data consistently' do
    tagger.musicbrainz_recording_id.should      eql('e1402418-eaea-4108-81e3-a12c22178325')
    tagger.musicbrainz_track_id.should          be(nil)
    tagger.musicbrainz_release_type.should      eql(['album'])
    tagger.musicbrainz_album_artist_id.should   eql('73fdb566-a9b1-494c-9f32-51768ec9fd27')
    tagger.musicbrainz_artist_id.count.should   be(2)
    tagger.musicbrainz_artist_id.should         include('73fdb566-a9b1-494c-9f32-51768ec9fd27')
    tagger.musicbrainz_artist_id.should         include('9facf8dc-df23-4561-85c5-ece75d692f21')
    tagger.musicbrainz_album_id.should          eql('468cd19e-d55c-46a2-a5a6-66292d2f0a90')
    tagger.musicbrainz_release_group_id.should  eql('fa64febd-61e0-346e-aaa2-04564ed4f0a3')
    tagger.musicbrainz_release_country.should   eql('US')
    tagger.musicbrainz_release_status.should    eql('official')
  end
end