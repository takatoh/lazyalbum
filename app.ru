require 'app'

use Rack::ShowExceptions

run LazyAlbumApp.new

