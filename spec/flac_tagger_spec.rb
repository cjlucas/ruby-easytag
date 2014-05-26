require_relative 'spec_helper'

describe EasyTag::FLACTagger do
  include_context 'no tags', EasyTag::FLACTagger.new(data_path('no_tags.flac'))
  include_context 'consistency', EasyTag::FLACTagger.new(data_path('consistency.flac'))
end
