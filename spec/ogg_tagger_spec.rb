require_relative 'spec_helper'

describe EasyTag::OggTagger do
  include_context 'no tags', EasyTag::OggTagger.new(data_path('no_tags.ogg'))
  include_context 'consistency', EasyTag::OggTagger.new(data_path('consistency.ogg'))
end
