EasyTag is an abstraction layer to the powerful [TagLib](http://taglib.github.io/) library. This project is designed to provide a simple and consistent API regardless of file format.

A quick reference to which attributes are currently supported can be found [here](https://github.com/cjlucas/ruby-easytag/wiki/Currently-Supported-Attributes).

[![Build Status (master)](https://travis-ci.org/cjlucas/ruby-easytag.png?branch=master "Branch: master")](https://travis-ci.org/cjlucas/ruby-easytag)
[![Build Status (develop)](https://travis-ci.org/cjlucas/ruby-easytag.png?branch=develop "Branch: develop")](https://travis-ci.org/cjlucas/ruby-easytag)

---
## Synopsis ##
```ruby
require 'easytag'

mp3 = EasyTag::File.new("01 Shout Out Loud.mp3")

# easy access to attributes
mp3.title
# => "Shout Out Loud"
mp3.artist
# => "Amos Lee"
mp3.year
# => 2006
mp3.date
# => #<DateTime: 2006-10-03T00:00:00+00:00 ((2454012j,0s,0n),+0s,2299161j)>
mp3.album_art
# => [#<EasyTag::Image:0x007f7fa542f528>]

# get access to the taglib-powered backend
mp3.info
# => #<TagLib::MPEG::File:0x007f7fa539e050 @__swigtype__="_p_TagLib__MPEG__File">
mp3.close

# A block interface is also available
EasyTag::File.open('01 Shout Out Loud.m4a') do |m4a|
  puts m4a.title
  puts m4a.comments
  puts m4a.genre
end
```
## Requirements ##
- Ruby versions
  - 1.9
  - 2.0
- Dependencies
  - [TagLib](http://taglib.github.io/) (1.8+)
  - [taglib-ruby](https://github.com/robinst/taglib-ruby) (0.6.0+)

## TODO ##
- API Documentation
- FLAC and OGG support
- Write support
