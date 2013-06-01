require 'test/unit'

require 'easytag'

TEST_DIR = File.dirname(File.absolute_path(__FILE__)) << File::SEPARATOR

class TestID3v1OnlyMP3 < Test::Unit::TestCase
  def setup
    @f = EasyTag::File.new("#{TEST_DIR}only_id3v1.mp3")
  end

  def test_tags
    assert_equal('Track Title',         @f.title)
    assert_equal('Track Artist',        @f.artist)
    assert_equal('Album Name',          @f.album)
    assert_equal(['this is a comment'], @f.comments)
    assert_equal('Swing',               @f.genre)
    assert_equal(1988,                  @f.year)
    assert_equal(1988,                  @f.date.year)
    assert_equal(true,                  @f.album_art.empty?)
    #assert_equal('',                   @f.apple_id)
    assert_equal([3, 0],                @f.track_num)
    assert_equal([0, 0],                @f.disc_num)

  end
end

class TestID3v2OnlyMP3 < Test::Unit::TestCase
  def setup
    @f = EasyTag::File.new("#{TEST_DIR}only_id3v2.mp3")
  end

  def test_tags
    assert_equal('Track Title',       @f.title)
    assert_equal('Track Artist',      @f.artist)
    assert_equal('Album Name',        @f.album)
    assert_equal('this is a comment', @f.comment)
    assert_equal('Swing',             @f.genre)
    assert_equal(1988,                @f.year)
    assert_equal(1988,                @f.date.year)
    assert_equal(true,                @f.album_art.empty?)
    #assert_equal('',                 @f.apple_id)
    assert_equal([3, 0],              @f.track_num)
    assert_equal([0, 0],              @f.disc_num)

  end
end

class TestNoTagsMP3 < Test::Unit::TestCase
  def setup
    @f = EasyTag::File.new("#{TEST_DIR}no_tags.mp3")
  end

  def test_tags
    assert_equal('',  @f.title)
    assert_equal('',  @f.artist)
    assert_equal('',  @f.album)
    assert_equal('',  @f.album_artist)
    assert_equal([],  @f.comments)
    assert_equal('',  @f.genre)
    assert_equal(0,    @f.year)
    assert_equal(nil,  @f.date)
    assert_equal(true, @f.album_art.empty?)
    #assert_equal('',  @f.apple_id)
    assert_equal([0, 0],  @f.track_num)
    assert_equal([0, 0],  @f.disc_num)
  end

  def test_musicbrainz_data
    assert_equal('', @f.musicbrainz_album_artist_id)
    assert_equal('', @f.musicbrainz_album_status)
    assert_equal('', @f.musicbrainz_release_group_id)
    assert_equal('', @f.musicbrainz_album_id)
    assert_equal([], @f.musicbrainz_album_type)
    assert_equal('', @f.musicbrainz_track_id)
    assert_equal('', @f.musicbrainz_album_release_country)
    assert_equal([], @f.musicbrainz_artist_id)
  end

end
