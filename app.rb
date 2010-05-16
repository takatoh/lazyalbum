#
#  LazyAlbum Web App.
#


require 'rubygems'
require 'sinatra/base'
require 'erb'

$:.unshift("#{File.dirname(__FILE__)}/lib")
require 'lazy_album'


class LazyAlbumApp < Sinatra::Base

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end

  include LazyAlbum::HTMLHelper


  set :run, true

  enable :static
  set :public, File.dirname(__FILE__) + "/public"
  enable :methodoverride
  enable :sessions


  ## Methods
  def odd_or_even(n)
    ["even", "odd"][n % 2]
  end


  # Index
  get '/' do
    @config = LazyAlbum::Config.instance
    @page_title = @config.page_title
    @ents = LazyAlbum::Entries.new.serch
    @items = @ents.to_array
    @items.sort!{|a, b| a[:title] <=> b[:title] }
    erb :index
  end

  # Send thumbnail
  get '/images/*.thumbnail' do
    @config = LazyAlbum::Config.instance
    path = params[:splat][0].split('/')
    entry = path[0..-2].join('/')
    thumbnail = "tn_" + path.last
    send_file "#{@config.data_dir}/#{entry}/.thumbnail/#{thumbnail}"
  end

  # Send picture
  get '/images/*' do
    @config = LazyAlbum::Config.instance
    send_file "#{@config.data_dir}/#{params[:splat][0]}"
  end

  # Picture
  get '/*' do
    @config = LazyAlbum::Config.instance
    pathes = params[:splat][0].split("/")
    @picture = pathes[-1]
    pass unless LazyAlbum.picture?(@picture)
    @entry = pathes[0..-2].join("/")
    erb :picture
  end

  # Entry
  get '/*' do
    @config = LazyAlbum::Config.instance
    @entry = params[:splat][0].sub(/\A\//, "")

    @ent = LazyAlbum::Entry.new(@entry)
    begin
      @ent.read
    rescue LazyAlbum::NoDataFileError
    end
    @title = @ent.title || "(no title)"
    @items = @ent.pictures

    @ent.search
    @sub_entries = @ent.sub_entries.to_array
    @sub_entries.sort!{|a, b| a[:title] <=> b[:title] }
    @ent.make_thumbnail_all

    erb :entry
  end

end
