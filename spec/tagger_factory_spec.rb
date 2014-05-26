require_relative 'spec_helper'

def tagger_for_signature_helper(file)
  fp = File.open(data_path(file), 'rb')
  data = fp.read(16)
  fp.close
  EasyTag::TaggerFactory.tagger_for_signature(data.bytes)
end

describe EasyTag::TaggerFactory do
  it 'should return the correct tagger class based on filename' do
    EasyTag::TaggerFactory.tagger_for_filename('file.mp3').should   be(EasyTag::MP3Tagger)
    EasyTag::TaggerFactory.tagger_for_filename('file.mp4').should   be(EasyTag::MP4Tagger)
    EasyTag::TaggerFactory.tagger_for_filename('file.m4a').should   be(EasyTag::MP4Tagger)
    EasyTag::TaggerFactory.tagger_for_filename('file.flac').should  be(EasyTag::FLACTagger)
    EasyTag::TaggerFactory.tagger_for_filename('file.ogg').should   be(EasyTag::OggTagger)
  end

  it 'should return the correct tagger class based on the file signature' do
    tagger_for_signature_helper('consistency.mp3').should   be(EasyTag::MP3Tagger)
    tagger_for_signature_helper('only_id3v1.mp3').should    be(EasyTag::MP3Tagger)
    tagger_for_signature_helper('only_id3v2.mp3').should    be(EasyTag::MP3Tagger)
    tagger_for_signature_helper('consistency.m4a').should   be(EasyTag::MP4Tagger)
    tagger_for_signature_helper('consistency.flac').should  be(EasyTag::FLACTagger)
    tagger_for_signature_helper('consistency.ogg').should   be(EasyTag::OggTagger)
  end
end