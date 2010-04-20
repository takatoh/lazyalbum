#!C:/usr/ruby/bin/ruby.exe -Ku
#
# make_thumbnail.rb
#

require 'rubygems'
require 'rmagick'
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
  geometry = Magick::Geometry.from_s("150x150")
  img = Magick::Image.read("#{entry.path}/#{pic}").first
  thumbnail = img.change_geometry(geometry) do |cols, rows, i|
    i.resize!(cols, rows)
  end
  thumbnail.write("#{thumb_dir}/tn_#{pic}")
end

