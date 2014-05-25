require_relative 'spec_helper'

describe EasyTag::TaggerFactory do
  it 'should return the correct tagger class based on filename' do
    EasyTag::TaggerFactory.tagger_for_filename('file.mp3').should be(EasyTag::MP3Tagger)
    EasyTag::TaggerFactory.tagger_for_filename('file.mp4').should be(EasyTag::MP4Tagger)
    EasyTag::TaggerFactory.tagger_for_filename('file.m4a').should be(EasyTag::MP4Tagger)
    EasyTag::TaggerFactory.tagger_for_filename('file.flac').should be(EasyTag::FLACTagger)
    EasyTag::TaggerFactory.tagger_for_filename('file.ogg').should be(EasyTag::OggTagger)
  end
end