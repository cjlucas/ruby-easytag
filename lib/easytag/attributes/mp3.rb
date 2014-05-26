require 'taglib'

require 'easytag/image'
require 'easytag/util'
require 'easytag/attributes/base'

module EasyTag
  module MP3AttributeAccessors
    include BaseAttributeAccessors

    def single_tag_reader(attr_name, id3v2_frames = nil, id3v1_tag = nil, **opts)
      id3v2_frames = Array(id3v2_frames)
      define_method(attr_name) do
        v = self.class.read_first_tag(taglib, id3v2_frames, id3v1_tag, opts)
        self.class.post_process(v, opts)
      end
    end

    def all_tags_reader(attr_name, id3v2_frames = nil, id3v1_tag = nil, **opts)
      id3v2_frames = Array(id3v2_frames)
      define_method(attr_name) do
        v = self.class.read_all_tags(taglib, id3v2_frames, id3v1_tag, opts)
        self.class.post_process(v, opts)
      end
    end

    def user_info_reader(attr_name, key = nil, **opts)
      key = attr_name if key.nil?
      define_method(attr_name) do
        @user_info = self.class.read_user_info(taglib, **opts) if @user_info.nil?
        self.class.post_process(@user_info[key], opts)
      end
    end

    def ufid_reader(attr_name, owner, **opts)
      define_method(attr_name) do
        v = self.class.read_ufid(taglib, owner, opts)
        self.class.post_process(v, opts)
      end
    end

    def date_reader(attr_name, **opts)
      opts[:returns] = :datetime unless opts.has_key?(:returns)
      define_method(attr_name) do
        v = self.class.read_date(taglib, opts)
        self.class.post_process(v, opts)
      end
    end

    # gets data from each frame id given only falls back
    # to the id3v1 tag if no id3v2 frames were found
    def read_all_tags(taglib, id3v2_frames, id3v1_tag = nil, **opts)
      frames = []
      id3v2_frames.each { |frame_id| frames += id3v2_frames(taglib, frame_id) }

      data = []
      # only check id3v1 if no id3v2 frames found
      if frames.empty?
        data << id3v1_tag(taglib, id3v1_tag) unless id3v1_tag.nil?
      else
        frames.each { |frame| data << data_from_frame(frame, **opts) }
      end

      data.compact
    end

    def read_first_tag(taglib, id3v2_frames, id3v1_tag = nil, **opts)
      read_all_tags(taglib, id3v2_frames, id3v1_tag, **opts).first
    end

    def id3v1_tag(taglib, tag_name)
      return nil if taglib.id3v1_tag.empty?
      v = taglib.id3v1_tag.send(tag_name)
      # TEMPFIX: nonexistent id3v1 tags return an empty string (taglib-ruby issue #49)
      case
      when v.is_a?(Fixnum) && v.zero?
        nil
      when v.is_a?(String) && v.empty?
        nil
      else
        v
      end
    end

    def id3v2_frames(taglib, frame_id)
      taglib.id3v2_tag.frame_list(frame_id)
    end

    def data_from_frame(frame, **opts)
      case
      when frame.is_a?(TagLib::ID3v2::TextIdentificationFrame)
        field_list = frame.field_list
        opts[:field_list] ? field_list : field_list.first
      when frame.is_a?(TagLib::ID3v2::UnsynchronizedLyricsFrame)
        frame.text
      when frame.is_a?(TagLib::ID3v2::CommentsFrame)
        frame.text
      when frame.is_a?(TagLib::ID3v2::AttachedPictureFrame)
        EasyTag::Image.new(frame.picture).tap do |img|
          img.desc = frame.description
          img.type = frame.type
          img.mime_type = frame.mime_type
        end
      else
        nil
      end
    end

    def read_user_info(taglib, **opts)
      user_info = {}
      frame_data = read_all_tags(taglib, ['TXXX'], nil, {field_list: true})

      frame_data.each do |data|
        key = data[0]
        values = data[1..-1]

        user_info[key] = values.count > 1 ? values : values.first
      end

      user_info
    end

    # NOTE: id3v2.3 tags (TYER+TDAT) will lose month/day information due to taglib's
    # internal frame conversion. During the conversion, the TDAT frame is
    # dropped and only the TYER frame is used in the conversion to TDRC.
    # (see: https://github.com/taglib/taglib/issues/127)
    def read_date(taglib, **opts)
      v10_year = taglib.id3v1_tag.year.to_s if taglib.id3v1_tag.year > 0
      v24_date = read_first_tag(taglib, ['TDRC'])

      # check variables in order of importance
      date_str = v24_date || v10_year
      puts "MP3#date: date_str = \"#{date_str}\"" if $DEBUG

      date_str
    end

    def read_ufid(taglib, owner, opts)
      frames = taglib.id3v2_tag.frame_list('UFID')
      frames.each { |frame| return frame.identifier if owner.eql?(frame.owner) }
      nil
    end
  end
end

