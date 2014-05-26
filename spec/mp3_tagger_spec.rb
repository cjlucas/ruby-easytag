require_relative 'spec_helper'

describe EasyTag::MP3Tagger do
  before(:all) do
    @id3v1_only     = EasyTag::MP3Tagger.new(data_path('only_id3v1.mp3'))
    @id3v2_only     = EasyTag::MP3Tagger.new(data_path('only_id3v2.mp3'))
    @no_tags        = EasyTag::MP3Tagger.new(data_path('no_tags.mp3'))
  end

  after(:all) do
    easytag_close @id3v1_only, @id3v2_only, @no_tags
  end

  include_context 'no tags', described_class.new(data_path('no_tags.mp3'))
  include_context 'consistency', described_class.new(data_path('consistency.mp3'))
  include_context 'consistency with multiple images', described_class.new(data_path('consistency.multiple_images.mp3'))

  context 'when containing only id3v1 tags' do
    it 'should read all id3v1 tags correctly' do
      @id3v1_only.title.should        eql('Track Title')
      @id3v1_only.artist.should       eql('Track Artist')
      @id3v1_only.album.should        eql('Album Name')
      @id3v1_only.comments.should     eql(['this is a comment'])
      @id3v1_only.genre.should        eql('Swing')
      @id3v1_only.year.should         be(1988)
      @id3v1_only.date.year.should    be(1988)
      @id3v1_only.track_number.should be(3)
      @id3v1_only.total_tracks.should be(nil)
      @id3v1_only.disc_number.should  be(nil)
      @id3v1_only.total_discs.should  be(nil)
    end

    it 'should return proper responses for attributes that require id3v2' do
      @id3v1_only.album_art.empty?.should be(true)
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
      @id3v2_only.track_number.should be(3)
      @id3v2_only.total_tracks.should be(nil)
      @id3v2_only.disc_number.should  be(nil)
      @id3v2_only.total_discs.should  be(nil)
    end
  end

  it 'should return the audio properties of the track' do
    @no_tags.length.should              be(4)
    @no_tags.bitrate.should             be(74)
    @no_tags.sample_rate.should         be(44100)
    @no_tags.channels.should            be(2)
    @no_tags.layer.should               be(3)
    @no_tags.original?.should           be(true)
    @no_tags.copyrighted?.should        be(false)
    @no_tags.protection_enabled?.should be(false)
  end
end