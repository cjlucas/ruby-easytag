require_relative 'spec_helper'

describe EasyTag::FLACTagger do
  before(:all) do
    @no_tags = described_class.new(data_path('no_tags.flac'))
  end

  after(:all) do
    easytag_close @no_tags
  end

  include_context 'no tags', described_class.new(data_path('no_tags.flac'))
  include_context 'consistency', described_class.new(data_path('consistency.flac'))
  include_context 'consistency with multiple images', described_class.new(data_path('consistency.multiple_images.flac'))

  it 'should return the audio properties of the track correctly' do
    @no_tags.length.should              be(4)
    @no_tags.bitrate.should             be(250)
    @no_tags.channels.should            be(2)
    @no_tags.sample_rate.should         be(44100)
    @no_tags.sample_width.should        be(16)
    @no_tags.signature.bytes.should     eql([97, 202, 139, 118, 67, 37, 2, 125, 159, 68, 118, 5, 249, 172, 220, 101])
  end
end
