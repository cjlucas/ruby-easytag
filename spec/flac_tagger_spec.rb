require_relative 'spec_helper'

describe EasyTag::FLACTagger do
  include_context 'no tags', described_class.new(data_path('no_tags.flac'))
  include_context 'consistency', described_class.new(data_path('consistency.flac'))
  include_context 'consistency with multiple images', described_class.new(data_path('consistency.multiple_images.flac'))
end
