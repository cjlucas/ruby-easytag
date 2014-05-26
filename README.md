EasyTag is an abstract interface to the [TagLib](http://taglib.github.io/) audio tagging library. It is designed to provide a simple and consistent API regardless of file format being read.

Currently support file formats are: MP3, MP4, FLAC, and Ogg.
A quick reference to which attributes are currently supported can be found [here](https://github.com/cjlucas/ruby-easytag/wiki/Currently-Supported-Attributes).

[![Build Status (master)](https://travis-ci.org/cjlucas/ruby-easytag.png?branch=master "Branch: master")](https://travis-ci.org/cjlucas/ruby-easytag)
[![Build Status (develop)](https://travis-ci.org/cjlucas/ruby-easytag.png?branch=develop "Branch: develop")](https://travis-ci.org/cjlucas/ruby-easytag)

NOTE: v0.6.0+ is not compatible with any version prior to v0.6.0.

---
## Synopsis ##

```ruby
require 'easytag'

tagger = EasyTag.open('audio.flac') # calls EasyTag::TaggerFactory::open
tagger                       # => <EasyTag::FLACTagger:0x007fc28aba4c90>
tagger.title                 # => "She Lives in My Lap"
tagger.artist                # => "OutKast feat. Rosario Dawson"
tagger.album_artist          # => "OutKast"
tagger.musicbrainz_artist_id # => ["73fdb566-a9b1-494c-9f32-51768ec9fd27", "9facf8dc-df23-4561-85c5-ece75d692f21"]

# The backing taglib object is also available 
f.taglib # => <TagLib::FLAC::File:0x007fc28aba4c68 @__swigtype__="_p_TagLib__FLAC__File">

f.close

# A block can also be specified
EasyTag.open('audio.flac') do |tagger|
 tagger.title         # => "She Lives in My Lap"
 tagger.artist        # => "OutKast feat. Rosario Dawson"
 tagger.album_artist  # => "OutKast"
 
 # tagger.close will be called after the block is executed
end
```


## Requirements ##
- Ruby versions
  - 2.0
  - 2.1
- Dependencies
  - [TagLib](http://taglib.github.io/) (1.8+)
  - [taglib-ruby](https://github.com/robinst/taglib-ruby) (0.6.0+)
  - [ruby-imagespec](https://github.com/andersonbrandon/ruby-imagespec)

## TODO ##
- API Documentation
- Write support
