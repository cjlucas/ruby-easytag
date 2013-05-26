require 'digest/sha1'
require 'test/unit'

require 'easytag'

TEST_DIR = File.dirname(File.absolute_path(__FILE__)) << File::SEPARATOR

class TestConsistencyMP301 < Test::Unit::TestCase
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
    assert_equal([5, 0],                @mp3.track_num)
    assert_equal([3, 0],                @mp3.disc_num)
    assert_equal(false,                 @mp3.compilation?)
    assert_equal(0,                     @mp3.bpm)
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

class TestConsistency01 < Test::Unit::TestCase
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

end

class TestConsistencyMP302 < Test::Unit::TestCase
  def setup
    @mp3 = EasyTag::File.new("#{TEST_DIR}consistency.02.mp3")
  end

  def test_tags
    cases = [
      ['She Lives in My Lap',           @mp3.title],
      [nil,                             @mp3.title_sort_order],
      ['OutKast feat. Rosario Dawson',  @mp3.artist],
      ['OutKast feat. Dawson, Rosario', @mp3.artist_sort_order],
      ['OutKast',                       @mp3.album_artist],
      #[nil,                             @mp3.album_artist_sort_order],
      ['Speakerboxxx / The Love Below', @mp3.album],
      [nil,                             @mp3.album_sort_order],
      [nil,                             @mp3.comments],
      [nil,                             @mp3.genre],
      [2003,                            @mp3.year],
      [[8, 21],                         @mp3.track_num],
      [[2, 2],                          @mp3.disc_num],
      ['The Love Below',                @mp3.disc_subtitle],
      ['CD',                            @mp3.media],
      ['Arista',                        @mp3.label],
      [true,                            @mp3.compilation?],
      [0,                               @mp3.bpm],
    ]

    cases.each do |c|
      expected, actual = c
      assert_equal(expected, actual)
    end
  end

  def test_date
    assert_equal(2003, @mp3.date.year)
    assert_equal(9,   @mp3.date.month)
    assert_equal(23,    @mp3.date.day)

    assert_equal(2003, @mp3.original_date.year)
    assert_equal(9,   @mp3.original_date.month)
    assert_equal(23,    @mp3.original_date.day)
  end

  def test_album_art
    assert_equal(1, @mp3.album_art.count)

    #sha1 = Digest::SHA1.hexdigest(@mp3.album_art[0].data)
    #assert_equal('this is the front cover', @mp3.album_art[0].desc)
    #assert_equal('Cover (front)',           @mp3.album_art[0].type_s)
    #assert_equal('image/jpeg',              @mp3.album_art[0].mime_type)
    #assert_equal(10,                        @mp3.album_art[0].width)
    #assert_equal(5,                         @mp3.album_art[0].height)
    #assert_equal('6555697ca1bf96117608bfb5a44c05cb622f88eb', sha1)
  end
end

class TestConsistency02 < Test::Unit::TestCase
  def setup
    @mp3 = EasyTag::File.new("#{TEST_DIR}consistency.02.mp3")
    @mp4 = EasyTag::File.new("#{TEST_DIR}consistency.02.m4a")
  end

  def test_tags
    cases = [
      :title,
      :title_sort_order,
      :artist,
      :artist_sort_order,
      #:album_artist_sort_order, # MP3 isn't working
      :album,
      :album_sort_order,
      :comments,
      :genre,
      :year,
      :track_num,
      :disc_num,
      :disc_subtitle,
      :media,
      :label,
      :compilation?,
      :bpm,
    ]

    cases.each do |c|
      puts c
      assert_equal(@mp3.send(c), @mp4.send(c))
    end
  end

  def test_date
    assert_equal(@mp3.date.year, @mp4.date.year)
    assert_equal(@mp3.date.month, @mp4.date.month)
    assert_equal(@mp3.date.day, @mp4.date.day)
  end

  def test_album_art
    # we're limited to what we can compare here, since mp4 is so limited
    img_mp3 = @mp3.album_art[0]
    img_mp4 = @mp4.album_art[0]
    assert_equal(img_mp3.mime_type, img_mp4.mime_type)
    assert_equal(img_mp3.data, img_mp4.data)
  end

end

