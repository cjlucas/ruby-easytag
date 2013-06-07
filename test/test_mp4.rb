require 'test/unit'

require 'easytag'

TEST_DIR = File.dirname(File.absolute_path(__FILE__)) << File::SEPARATOR

class TestNoTagsMP4 < Test::Unit::TestCase
  def setup
    @f = EasyTag::File.new("#{TEST_DIR}no_tags.m4a")
  end

  def test_tags
    assert_equal('',    @f.title)
    assert_equal('',    @f.artist)
    assert_equal('',    @f.album)
    assert_equal('',    @f.album_artist)
    assert_equal([],     @f.comments)
    assert_equal('',    @f.genre)
    assert_equal(0,      @f.year)
    assert_equal(nil,    @f.date)
    assert_equal(true,   @f.album_art.empty?)
    assert_equal('',    @f.apple_id)
    assert_equal([0, 0], @f.track_num)
    assert_equal([0, 0], @f.disc_num)
    assert_equal('',    @f.conductor)
    assert_equal('',    @f.remixer)
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

  def test_audio_properties
    assert_equal(4,     @f.duration)
    assert_equal(176,   @f.bitrate)
    assert_equal(44100, @f.sample_rate)
    assert_equal(2,     @f.channels)
    assert_equal(16,    @f.bits_per_sample)
  end

end
