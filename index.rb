#!C:/usr/ruby/bin/ruby.exe -Ku
#
# LazyAlbum
#
#--
#  $Id: index.rb 94 2009-03-18 11:27:35Z 24711 $

begin

require 'cgi'
require 'erb'
$:.unshift("#{File.dirname(__FILE__)}/lib")
require 'lazy_album'
require 'lazy_album/config'
require 'lazy_album/entry'
require 'lazy_album/html_helper'

include LazyAlbum::HTMLHelper

## Config
config = LazyAlbum::Config.instance
page_title = config.page_title
cgi_url = config.cgi_url
data_dir = config.data_dir
ps_url = cgi_url.sub("index.rb", "ps.rb")
stylesheet = config.stylesheet

## Methods
def out(template, bind)
  print "Content-type: text/html\n\n"
  script = ERB.new(File.read(template), nil, "%>")
  script.run(bind)
end

def odd_or_even(n)
  ["even", "odd"][n % 2]
end

## Main
cgi = CGI.new
if cgi.include?('e')
  entry = cgi.params['e'][0]
  ent = LazyAlbum::Entry.new(entry)
  begin
    ent.read
  rescue LazyAlbum::NoDataFileError
  end
  title = ent.title || "(no title)"
  items = ent.pictures
end
if cgi.include?('p')
  picture = cgi.params['p'][0]
end

if entry && picture
  out("templates/picture.rhtml", binding)
elsif entry
  ent.search
  sub_entries = ent.sub_entries.to_array
  sub_entries.sort!{|a, b| a[:title] <=> b[:title] }
  ent.make_thumbnail_all
  out("templates/entry.rhtml", binding)
else
  ents = LazyAlbum::Entries.new.serch
  items = ents.to_array
  items.sort!{|a, b| a[:title] <=> b[:title] }
  out("templates/index.rhtml", binding)
end

rescue Exception => error
  print "Content-Type: text/plain\n\n"
  print "Error: #{error.message}\n"
  print "Error: #{error.backtrace}\n"
end
