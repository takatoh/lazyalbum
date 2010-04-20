#
# LazyAlbum::HTMLHelper
#
#--
#  $Id: html_helper.rb 109 2009-10-16 10:04:32Z 24711 $

require 'cgi'

module LazyAlbum

  module HTMLHelper

    def url_to_entry(entry_path)
      config = Config.instance
      "#{config.cgi_url}?e=#{CGI.escape(entry_path)}"
    end

    def url_to_picture_page(entry_path, picture)
      config = Config.instance
      "#{config.cgi_url}?e=#{CGI.escape(entry_path)};p=#{CGI.escape(picture)}"
    end

    def url_to_picture(entry_path, picture)
      config = Config.instance
      ps = config.cgi_url.sub("index.rb", "ps.rb")
      "#{ps}?e=#{CGI.escape(entry_path)};p=#{CGI.escape(picture)}"
    end

    def url_to_thumbnail(entry_path, picture)
      config = Config.instance
      ps = config.cgi_url.sub("index.rb", "ps.rb")
      "#{ps}?e=#{CGI.escape(entry_path)};p=#{CGI.escape(picture)};t=thumbnail"
    end

    def breadcrumbs(entry_path)
      config = Config.instance
      ent_ary = entry_path.split("/").delete_if{|e| e == ""}
      path_ary = ent_ary.inject([""]){|a,e| a << a.last + "/" + e}[1..-1]
      path_ary.zip(ent_ary).map do |e|
        "<a href=" + url_to_entry(e[0]) + ">" + e[1] + "</a>"
      end.unshift("<a href=" + config.cgi_url + ">Index</a>").join(" > ")
    end

  end   # of module LazyAlbum::HTMLHelper

end   # of module LazyAlbum
