require 'test/unit'

require 'easytag'

TEST_DIR = File.dirname(File.absolute_path(__FILE__)) << File::SEPARATOR

class TestID3v1OnlyMP3 < Test::Unit::TestCase
  def setup
    @mp3 = EasyTag::File.new("#{TEST_DIR}only_id3v1.mp3")
  end

  def test_tags
    assert_equal('Track Title',       @mp3.title)
    assert_equal('Track Artist',      @mp3.artist)
    assert_equal('Album Name',        @mp3.album)
    assert_equal('this is a comment', @mp3.comments)
    assert_equal('Swing',             @mp3.genre)
    assert_equal(1988,                @mp3.year)
  end
end

class TestNoTagsMP3 < Test::Unit::TestCase
  def setup
    @mp3 = EasyTag::File.new("#{TEST_DIR}no_tags.mp3")
  end

  def test_tags
    assert_equal(nil, @mp3.title)
    assert_equal(nil, @mp3.artist)
    assert_equal(nil, @mp3.album)
    assert_equal(nil, @mp3.comments)
    assert_equal(nil, @mp3.genre)
    assert_equal(nil, @mp3.year)
  end

end
