#
# LazyAlbum::Utils
#

require 'yaml'
require 'lazy_album/config'


module LazyAlbum

  module Utils

    @@config = Config.instance

    def conv_to_filesystem_encoding(str)
      if /UTF-8/i =~ @@config.file_system_encoding
        str
      else
        str.encode(@@config.file_system_encoding)
      end
    end
    module_function :conv_to_filesystem_encoding

    def conv_from_filesystem_encoding(str)
      if /UTF-8/i =~ @@config.file_system_encoding
        str
      else
        str.encode("UTF-8")
      end
    end
    module_function :conv_from_filesystem_encoding

  end   # of module Utils

end    # of module LazyAlbum
