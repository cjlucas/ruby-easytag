require 'test/unit'

require 'easytag'

TEST_DIR = File.dirname(File.absolute_path(__FILE__)) << File::SEPARATOR

class TestNoTagsMP4 < Test::Unit::TestCase
  def setup
    @f = EasyTag::File.new("#{TEST_DIR}no_tags.m4a")
  end

  def test_tags
    assert_equal(nil,    @f.title)
    assert_equal(nil,    @f.artist)
    assert_equal(nil,    @f.album)
    assert_equal(nil,    @f.album_artist)
    assert_equal(nil,    @f.comments)
    assert_equal(nil,    @f.genre)
    assert_equal(0,      @f.year)
    assert_equal(nil,    @f.date)
    assert_equal(true,   @f.album_art.empty?)
    assert_equal(nil,    @f.apple_id)
    assert_equal([0, 0], @f.track_num)
    assert_equal([0, 0], @f.disc_num)
  end

end

class TestMusicBrainzMP4 < Test::Unit::TestCase
  def setup
    @f = EasyTag::File.new("#{TEST_DIR}musicbrainz.m4a")
  end

  def test_tags
    assert_equal('Take Off Your Cool',            @f.title)
    assert_equal('OutKast feat. Norah Jones',     @f.artist)
    assert_equal('Speakerboxxx / The Love Below', @f.album)
    assert_equal('OutKast',                       @f.album_artist)
    assert_equal(nil,                             @f.comments)
    assert_equal(nil,                             @f.genre)
    assert_equal(2003,                            @f.year)
    assert_equal(1,                               @f.album_art.count)
    assert_equal(nil,                             @f.apple_id)
    assert_equal([18, 20],                        @f.track_num)
    assert_equal([2, 2],                          @f.disc_num)
  end

  def test_date
    assert_equal(2003, @f.date.year)
    assert_equal(9,    @f.date.month)
    assert_equal(29,   @f.date.day)
  end

end

