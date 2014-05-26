require_relative 'spec_helper'

describe EasyTag::OggTagger do
  include_context 'no tags', described_class.new(data_path('no_tags.ogg'))
  include_context 'consistency', described_class.new(data_path('consistency.ogg'))
  include_context 'consistency with multiple images', described_class.new(data_path('consistency.multiple_images.ogg'))
end
