require_relative 'spec_helper'

describe EasyTag do
  before(:all) do
    @mp3_01 = EasyTag::MP3Tagger.new(data_path('consistency.01.mp3'))
    @consistency01taggers = [@mp3_01]
  end

  after(:all) do
    [@mp3_01].each { |et| et.taglib.close }
  end
  context 'consistency.01' do
    it 'should read all attributes properly' do
      @consistency01taggers.each do |tagger|
        tagger.title.should eql('Track Title')
        tagger.artist.should eql('Artist Name Here')
        tagger.album_artist.should eql('Album Artist Here')
        tagger.album.should eql('Album Name Here')
        tagger.comments.should eql(['This is my comment.'])
        tagger.genre.should eql('Polka')
        tagger.year.should eql(1941)
        tagger.date.year.should eql(1941)
        tagger.date.month.should eql(12)
        tagger.date.day.should eql(7)
        tagger.track_num.should eql([5, 0])
        tagger.disc_num.should eql([3, 0])

        expect(tagger.bpm).to           be(0)
        expect(tagger.compilation?).to  be_false
      end
    end
  end
end

