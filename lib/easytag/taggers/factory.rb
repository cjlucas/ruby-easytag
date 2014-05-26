module EasyTag
  class TaggerFactory
    def self.open(file, &block)
      tagger_klass = tagger_class(file)

      if block_given?
        tagger = tagger_klass.new(file)
        begin
          block.call(tagger)
        ensure
          tagger.close
        end
      else
        tagger_klass.new(file)
      end
    end

    def self.tagger_class(file)
      tagger_klass = tagger_for_filename(file)
      if tagger_klass.nil?
        data = nil
        File.open(file, 'rb') { |fp| data = fp.read(16) }
        tagger_klass = tagger_for_signature(data.bytes)
      end

      raise 'Could not determine file type' if tagger_klass.nil?
      tagger_klass
    end

    def self.tagger_for_filename(fname)
      case fname.split('.')[-1].downcase.to_sym
      when :mp3; MP3Tagger
      when :mp4, :m4a; MP4Tagger
      when :flac; FLACTagger
      when :ogg; OggTagger
      else; nil
      end
    end

    def self.tagger_for_signature(bytes)
      case
      when bytes[0...11] == [0, 0, 0, 32, 102, 116, 121, 112, 77, 52, 65] # ...ftypM4A
        MP4Tagger
      when bytes[0...11] == [0, 0, 0, 24, 102, 116, 121, 112, 109, 112, 52] # ...ftypmp4
        MP4Tagger
      when bytes[0...4] == [102, 76, 97, 67] # fLaC
        FLACTagger
      when bytes[0...4] == [79, 103, 103, 83] # OggS
        OggTagger
      when bytes[0...3] == [73, 68, 51] # ID3
        MP3Tagger
      when bytes[0...2] == [255, 251] # FF FB
        MP3Tagger
      else
        nil
      end
    end
  end
end