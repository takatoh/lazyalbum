#!C:/usr/ruby/bin/ruby.exe -Ku
#
#  PictureSender
#

require 'cgi'
$:.unshift("#{File.dirname(__FILE__)}/lib")
require 'lazy_album'

## Config
config = LazyAlbum::Config.instance

MEDIATYPES = {
  "txt"   => "text/plain",
  "gif"   => "image/gif",
  "jpg"   => "image/jpeg",
  "jpeg"  => "image/jpeg",
  "png"   => "image/png",
  "tif"   => "image/tiff",
  "tiff"  => "image/tiff",
  "bmp"   => "image/bmp"
}
MEDIATYPES.default = "application/octet-stream"

def mediatype(filename)
  ext = /\.([^.]+)$/.match(filename.downcase).to_a[1]
  MEDIATYPES[ext]
end

cgi = CGI.new
begin
  entry = cgi.params['e'][0]
  picture = "#{config.data_dir}/#{entry}/#{cgi.params['p'][0]}"
  if cgi.params['t'][0] == 'thumbnail'
    thumbnail = "#{config.data_dir}/#{entry}/.thumbnail/tn_#{cgi.params['p'][0]}"
    if File.exists?(thumbnail)
      picture = thumbnail
    end
  end
  f = File.open(picture, "rb")
  $stdout.binmode
  print "Content-type: #{mediatype(picture)}\n\n"
  print f.read
rescue Exception => error
  print "Content-type: text/plain\n\n"
  print "Your request is wrong.\n"
  print "Error: #{error.message}\n"
ensure
  f.close if f.kind_of?(File)
end

