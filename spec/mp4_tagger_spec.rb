require_relative 'spec_helper'

describe EasyTag::MP4Tagger do
  before(:all) do
    @no_tags = described_class.new(data_path('no_tags.m4a'))
  end

  after(:all) do
    easytag_close @no_tags
  end

  include_context 'no tags', described_class.new(data_path('no_tags.m4a'))
  include_context 'consistency', described_class.new(data_path('consistency.m4a'))

  it 'should return the audio properties of the track correctly' do
    @no_tags.length.should          be(4)
    @no_tags.bitrate.should         be(176)
    @no_tags.channels.should        be(2)
    @no_tags.sample_rate.should     be(44100)
    @no_tags.bits_per_sample.should be(16)
  end
end