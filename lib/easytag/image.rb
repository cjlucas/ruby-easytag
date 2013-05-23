require 'image_spec'

module EasyTag
  # mimics constants of TagLib::ID3v2::AttachedPictureFrame
  class ImageType
    None               = -1
    Other              = 0
    FileIcon           = 1
    OtherFileIcon      = 2
    FrontCover         = 3
    BackCover          = 4
    LeafletPage        = 5
    Media              = 6
    LeadArtist         = 7
    Artist             = 8
    Conductor          = 9
    Band               = 10
    Composer           = 11
    Lyricist           = 12
    RecordingLocation  = 13
    DuringRecording    = 14
    DuringPerformance  = 15
    MovieScreenCapture = 16
    ColouredFish       = 17
    Illustration       = 18
    BandLogo           = 19
    PublisherLogo      = 20

    IMAGE_TYPE_TO_STRING_MAP = {
      None               => '',
      Other              => 'Other',
      FileIcon           => 'File Icon (small)',
      OtherFileIcon      => 'File Icon',
      FrontCover         => 'Cover (front)',
      BackCover          => 'Cover (back)',
      LeafletPage        => 'Leaflet',
      Media              => 'Media',
      LeadArtist         => 'Lead Artist',
      Artist             => 'Artist',
      Conductor          => 'Conductor',
      Band               => 'Band',
      Composer           => 'Composer',
      Lyricist           => 'Lyricist',
      RecordingLocation  => 'Recording Location',
      DuringRecording    => 'During Recording',
      DuringPerformance  => 'During Performance',
      MovieScreenCapture => 'Video Capture',
      ColouredFish       => 'A Bright Colored Fish',
      Illustration       => 'Illustration',
      BandLogo           => 'Band Logo',
      PublisherLogo      => 'Publisher Logo'
    }

  end

  class Image
    attr_reader :width, :height, :size
    attr_accessor :data, :desc, :mime_type, :type, :type_s

    def initialize(data)
      self.data = data
      type = ImageType::None
    end

    def type_s
      ImageType::IMAGE_TYPE_TO_STRING_MAP[type]
    end

    def data=(data)
      @data = data
      @size = @data.length

      begin
        spec = ImageSpec.new(StringIO.new(data, 'rb'))
        @mime_type = spec.content_type
        @width     = spec.width
        @height    = spec.height
      rescue ImageSpec::Error => e
        nil
      end
    end
  end
end

