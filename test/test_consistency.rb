require 'digest/sha1'
require 'test/unit'

require 'easytag'

TEST_DIR = File.dirname(File.absolute_path(__FILE__)) << File::SEPARATOR

class TestConsistencyMP3 < Test::Unit::TestCase
  def setup
    @mp3 = EasyTag::File.new("#{TEST_DIR}consistency.01.mp3")
  end

  def test_tags
    assert_equal('Track Title',         @mp3.title)
    assert_equal('Artist Name Here',    @mp3.artist)
    assert_equal('Album Artist Here',   @mp3.album_artist)
    assert_equal('Album Name Here',     @mp3.album)
    assert_equal('This is my comment.', @mp3.comments)
    assert_equal('Polka',               @mp3.genre)
    assert_equal(1941,                  @mp3.year)
  end

  def test_date
    assert_equal(1941, @mp3.date.year)
    assert_equal(12,   @mp3.date.month)
    assert_equal(7,    @mp3.date.day)
  end

  def test_album_art
    assert_equal(2, @mp3.album_art.count)

    sha1 = Digest::SHA1.hexdigest(@mp3.album_art[0].data)
    assert_equal('this is the front cover', @mp3.album_art[0].desc)
    assert_equal('Cover (front)',           @mp3.album_art[0].type_s)
    assert_equal('image/jpeg',              @mp3.album_art[0].mime_type)
    assert_equal(10,                        @mp3.album_art[0].width)
    assert_equal(5,                         @mp3.album_art[0].height)
    assert_equal('6555697ca1bf96117608bfb5a44c05cb622f88eb', sha1)

    sha1 = Digest::SHA1.hexdigest(@mp3.album_art[1].data)
    assert_equal('this is the artist', @mp3.album_art[1].desc)
    assert_equal('Artist',             @mp3.album_art[1].type_s)
    assert_equal('image/png',          @mp3.album_art[1].mime_type)
    assert_equal(10,                   @mp3.album_art[1].width)
    assert_equal(5,                    @mp3.album_art[1].height)
    assert_equal('9db2996823fb44ed64dfc8f57dc9df3b970c6b22', sha1)
  end
end

class TestConsistency < Test::Unit::TestCase
  def setup
    @mp3 = EasyTag::File.new("#{TEST_DIR}consistency.01.mp3")
    @mp4 = EasyTag::File.new("#{TEST_DIR}consistency.01.m4a")
  end

  def test_tags
    assert_equal(@mp3.title, @mp4.title)
    assert_equal(@mp3.artist, @mp4.artist)
    assert_equal(@mp3.album_artist, @mp4.album_artist)
    assert_equal(@mp3.album, @mp4.album)
    assert_equal(@mp3.comments, @mp4.comments)
    assert_equal(@mp3.genre, @mp4.genre)
    assert_equal(@mp3.year, @mp4.year)
  end

  def test_date
    # MP4 only supports year, so thats all we can test
    assert_equal(@mp3.date.year, @mp4.date.year)
  end

  def test_album_art
    # we're limited to what we can compare here, since mp4 is so limited
    img_mp3 = @mp3.album_art[0]
    img_mp4 = @mp4.album_art[0]
    assert_equal(img_mp3.mime_type, img_mp4.mime_type)
    assert_equal(img_mp3.data, img_mp4.data)
  end

  #def test_audio_data
    #assert_equal(true, (@mp3.duration - @mp4.duration).abs < 0.1)
  #end

end

