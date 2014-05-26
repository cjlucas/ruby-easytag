require_relative 'spec_helper'

describe EasyTag::MP4Tagger do
  include_context 'no tags', described_class.new(data_path('no_tags.m4a'))
  include_context 'consistency', described_class.new(data_path('consistency.m4a'))
end