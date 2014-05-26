require_relative 'spec_helper'

describe EasyTag::OggTagger do
  before(:all) do
    @no_tags = described_class.new(data_path('no_tags.ogg'))
  end
  include_context 'no tags', described_class.new(data_path('no_tags.ogg'))
  include_context 'consistency', described_class.new(data_path('consistency.ogg'))
  include_context 'consistency with multiple images', described_class.new(data_path('consistency.multiple_images.ogg'))

  it 'should return the audio properties of the track correctly' do
    @no_tags.length.should          be(4)
    @no_tags.bitrate.should         be(64)
    @no_tags.channels.should        be(2)
    @no_tags.sample_rate.should     be(44100)
    @no_tags.bitrate_maximum.should be(0)
    @no_tags.bitrate_minimum.should be(0)
    @no_tags.bitrate_nominal.should be(64000)
    @no_tags.vorbis_version.should  be(0)
  end
end
