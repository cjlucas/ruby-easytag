require_relative 'spec_helper'

describe EasyTag::MP4Tagger do
  before(:all) do
    @no_tags = EasyTag::MP4Tagger.new(data_path('no_tags.m4a'))
  end

  after(:all) do
    [@no_tags].each { |et| et.close }
  end

  include_context 'no tags', EasyTag::MP4Tagger.new(data_path('no_tags.m4a'))
  include_context 'consistency', EasyTag::MP4Tagger.new(data_path('consistency.m4a'))
end