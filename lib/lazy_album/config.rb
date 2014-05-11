# coding: utf-8
#
# LazyAlbum::Config
#

require 'inputfileparser'
require 'singleton'

module LazyAlbum

  class Config
    include Singleton

    CONFIG_FILE_NAME = "la.conf"

    KEYS = %w( data_dir stylesheet page_title file_system_encoding )

    KEYS.each{|k| attr_reader k.intern}

    def initialize
      set_default
      inputdata = InputFileScanner.new(KEYS, ":").scan(CONFIG_FILE_NAME)
      while pair = inputdata.shift
        key, val = pair
        instance_eval(%Q[@#{key} = "#{val.strip}"])
      end
      post_load
    end

    def set_default
      KEYS.each{|k| instance_eval(%Q[@#{k} = nil])}
    end

    def post_load
    end
  end   # of class LazyAlbum::Config

end   # of module LazyAlbum
