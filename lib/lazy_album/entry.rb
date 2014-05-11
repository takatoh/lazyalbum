# coding: utf-8
#
# LazyAlbum の画像ディレクトリを扱うためのライブラリ。
#

require 'find'
require 'yaml'

require 'lazy_album/utils'

module LazyAlbum

    # 画像として扱うファイルの拡張子の配列。
    PICTURE_EXT = ['.jpg', '.jpeg', '.bmp', '.pcx', '.png', '.gif']

    # データファイルの名前。
    DATAFILE = '.index.yaml'

    # サムネール用ディレクトリ名。
    THUMB_DIR_NAME = '.thumbnail'

    # データファイルがない
    class NoDataFileError < StandardError; end


    # file が画像ファイルであれば真を返す。
    # 画像ファイルか否かは，拡張子が LazyAlbum::PICTURE_EXT に挙げられている
    # 文字列と一致するか否かで判定する。
    def picture?(file)
      x = false
#      if File.file?(file)
        ext = /\.[^\.]*$/is.match(file).to_s.downcase
        x = PICTURE_EXT.member?(ext)
#      end
      x
    end
    module_function :picture?

    # path の直下に画像ファイルがあれば真を返す。
    def picture_exist?(path)
      path = File.expand_path(path)
      files = Dir.entries(path).collect{|f| File.join(path, f)}
      x = false
      files.each do |f|
        if picture?(f)
          x = true
          break
        end
      end
      x
    end
    module_function :picture_exist?

    # file がデータファイルファイルであれば真を返す。
    # データファイルか否かは，名前が LazyAlbum::DATAFILE と一致するか否かで判定する。
    def datafile?(file)
      if File.file?(file)
        DATAFILE == File.basename(file).downcase
      else
        false
      end
    end
    module_function :datafile?

    # path の直下にデータファイルがあれば真を返す。
    def datafile_exist?(path)
      files = Dir.entries(path).delete_if{|f| !File.file?(File.join(path, f))}
      files.member?(DATAFILE)
    end
    module_function :datafile_exist?

    # path の直下にデータファイルがあればそのファイル名を返す。
    # データファイルがなければ，nil を返す。
    def datafile(path)
      datafilename = File.join(path, DATAFILE)
      if File.exists?(datafilename)
        datafilename
      else
        nil
      end
    end
    module_function :datafile



    ##
    ## Classes
    ##

    class Entry

      include LazyAlbum::Utils

      # LazyAlbum::Entryオブジェクトを生成する。
      def initialize(entry_path)
        @config = Config.instance
        @base_path = File.expand_path(@config.data_dir)
        @entry_path = entry_path
        @path = File.join(@base_path, @entry_path)
        @title = File.basename(@path)
        @datafile = nil
        @data = nil
        @sub_entries = []
      end

      attr_reader   :base_path, :entry_path, :path
      attr_accessor :title
      attr_reader   :datafile
      attr_accessor :data
      attr_reader   :sub_entries

      # データファイルから情報を読み込み，自身を返す。
      def read
        datafilename = LazyAlbum.datafile(@path)
        raise NoDataFileError unless datafilename   # データファイルがなければ例外発生
        @data = YAML.load_file(datafilename)
        @attributes = @data["attributes"]
        @title = @attributes["title"]
        @datafile = File.basename(datafilename)
        self
      end

      # @path 以下のディレクトリを検索し、エントリを追加する。
      # 自身を返す。
      def search
        @sub_entries = LazyAlbum::Entries.new(@entry_path).serch
      end

      # エントリに含まれる画像ファイル名の配列を返す。
      def pictures
        files = Dir.glob("#{conv_to_filesystem_encoding(@path)}/*")
        files = files.delete_if{|f| !LazyAlbum.picture?(f)}
        files = files.collect{|f| File.basename(f)}
        files
      end

      # サムネイルディレクトリを作る。
      def make_thumb_dir
        thumb_dir = conv_to_filesystem_encoding(File.join(@path, THUMB_DIR_NAME))
        Dir.mkdir(thumb_dir)
        thumb_dir
      end

      # サムネイルを作る。
      def make_thumbnail_all
        thumb_dir = conv_to_filesystem_encoding(File.join(@path, THUMB_DIR_NAME))
        make_thumb_dir unless File.exist?(thumb_dir)
        pictures.each do |pic|
          thumb = File.join(thumb_dir, "tn_#{pic}")
          unless File.exists?(thumb)
            geometry = "150x150"
            system("convert -thumbnail #{geometry} #{File.join(@path, pic)} #{thumb}")
          end
        end
      end

    end    # class LazyAlbum::Entry


    class Entries

      include LazyAlbum::Utils

      # LazyAlbum::Entriesオブジェクトを生成する。@base_path 以外は空。
      def initialize(entry_path = "")
        @config = Config.instance
        @base_path = File.expand_path(@config.data_dir)
        @entry_path = entry_path
        @path = File.join(@base_path, @entry_path)
        @entries = []
      end

      attr_reader :base_path, :entry_path

      # @base_path 以下のディレクトリを検索し、エントリを追加する。
      # 自身を返す。
      def serch
        Dir.glob(conv_to_filesystem_encoding(File.join(@path, "*"))) do |f|
          next if /^\./ =~ File.basename(f)
          # 画像ファイルの在るディレクトリを対象とする。
#          if File.directory?(f) and LazyAlbum.picture_exist?(f)
          if File.directory?(f)
            entry = LazyAlbum::Entry.new(File.join(@entry_path, conv_from_filesystem_encoding(File.basename(f))))
            # もしデータファイルが在れば，それを読み込む。
            entry.read if LazyAlbum.datafile_exist?(f)
            @entries << entry
          end
        end
        self
      end

      # entry（LazyAlbum::Entryオブジェクト）を追加する。
      def add(entry); @entries << entry; end
      alias :<< :add

      # 各エントリに対してブロックを繰り返すイテレータ。
      def each(&block)
        @entries.each do |entry|
          yield(entry) if block_given?
        end
      end

      def to_array
        @entries.map do |e|
          { :path  => e.path,
            :entry => e.entry_path,
            :title => e.title
          }
        end
      end

      # エントリがなければ真を返す。
      def empty?
        @entries.empty?
      end

    end    # class LazyAlbum::Entries

end    # of module LazyAlbum

