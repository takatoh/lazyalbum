#
# LazyAlbum::HTMLHelper
#

require 'cgi'

module LazyAlbum

  module HTMLHelper

    def url_to_entry(entry_path)
      entry_path = entry_path.sub(/\A\//, "")
      entry_path.split("/").map{|p| CGI.escape(p)}.join("/")
      "/#{entry_path}"
    end

    def url_to_picture_page(entry_path, picture)
      "#{url_to_entry(entry_path)}/#{CGI.escape(picture)}"
    end

    def url_to_picture(entry_path, picture)
      "/images#{url_to_entry(entry_path)}/#{CGI.escape(picture)}"
    end

    def url_to_thumbnail(entry_path, picture)
      "/images#{url_to_entry(entry_path)}/#{CGI.escape(picture)}.thumbnail"
    end

    def breadcrumbs(entry_path)
      config = Config.instance
      ent_ary = entry_path.split("/").delete_if{|e| e == ""}
      path_ary = inits(ent_ary).map{|a| a.join("/")}
      path_ary.zip(ent_ary).map do |e|
        "<a href=" + url_to_entry(e[0]) + ">" + e[1] + "</a>"
      end.unshift("<a href=\"/\">Index</a>").join(" &#187; ")
    end


    def inits(ary)
      (1..(ary.size)).map{|n| ary.slice(0,n)}
    end

  end   # of module LazyAlbum::HTMLHelper

end   # of module LazyAlbum
