module EasyTag
  class TaggerFactory
    def self.open(file, &block)
      tagger_klass = tagger_for_filename(file)
      raise 'Could not determine file type' if tagger_klass.nil?

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

    def self.tagger_for_filename(fname)
      case fname.split('.')[-1].downcase.to_sym
      when :mp3; MP3Tagger
      when :mp4, :m4a; MP4Tagger
      when :flac; FLACTagger
      when :ogg; OggTagger
      else; nil
      end
    end
  end
end