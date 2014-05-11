#!ruby
# coding: utf-8
#
# make_thumbnail.rb
#

$:.unshift("#{File.dirname(__FILE__)}/lib")
require 'lazy_album'
require 'lazy_album/entry'

## Config
config = LazyAlbum::Config.instance
data_dir = config.data_dir


## Main
entry = LazyAlbum::Entry.new(ARGV.shift)
thumb_dir = entry.make_thumb_dir
entry.pictures.each do |pic|
  puts "Making thumbnail - #{pic}"
  thumb = File.join(thumb_dir, "tn_#{pic}")
  geometry = "150x150"
  system("convert -thumbnail #{geometry} #{File.join(entry.path, pic)} #{thumb}")
end

