#
# LazyAlbum::Utils
#

require 'yaml'
require 'iconv'
require 'lazy_album/config'


module LazyAlbum

  module Utils

    @@config = Config.instance

    def conv_to_filesystem_encoding(str)
      if /UTF-8/i =~ @@config.file_system_encoding
        str
      else
        Iconv.iconv(@@config.file_system_encoding, "UTF-8", str)[0]
      end
    end
    module_function :conv_to_filesystem_encoding

    def conv_from_filesystem_encoding(str)
      if /UTF-8/i =~ @@config.file_system_encoding
        str
      else
        Iconv.iconv("UTF-8", @@config.file_system_encoding, str)[0]
      end
    end
    module_function :conv_from_filesystem_encoding

  end   # of module Utils

end    # of module LazyAlbum
