#!ruby -Ks
#
# LazyAlbum �̉摜�f�B���N�g�����������߂̃��C�u�����B
#
#--
#  $Id: entry.rb 77 2009-03-17 06:35:27Z 24711 $

require 'find'
require 'jcode'
require 'yaml'
require 'rubygems'
require 'rmagick'

module LazyAlbum

    # �摜�Ƃ��Ĉ����t�@�C���̊g���q�̔z��B
    PICTURE_EXT = ['.jpg', '.jpeg' '.bmp', '.pcx', '.png', '.gif']

    # �f�[�^�t�@�C���̖��O�B
    DATAFILE = '.index.yaml'

    # �T���l�[���p�f�B���N�g�����B
    THUMB_DIR_NAME = '.thumbnail'

    # �f�[�^�t�@�C�����Ȃ�
    class NoDataFileError < StandardError; end


    # file ���摜�t�@�C���ł���ΐ^��Ԃ��B
    # �摜�t�@�C�����ۂ��́C�g���q�� LazyAlbum::PICTURE_EXT �ɋ������Ă���
    # ������ƈ�v���邩�ۂ��Ŕ��肷��B
    def picture?(file)
      x = false
      if File.file?(file)
        ext = /\.[^\.]*$/is.match(file).to_s.downcase
        x = PICTURE_EXT.member?(ext)
      end
      x
    end
    module_function :picture?

    # path �̒����ɉ摜�t�@�C��������ΐ^��Ԃ��B
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

    # file ���f�[�^�t�@�C���t�@�C���ł���ΐ^��Ԃ��B
    # �f�[�^�t�@�C�����ۂ��́C���O�� LazyAlbum::DATAFILE �ƈ�v���邩�ۂ��Ŕ��肷��B
    def datafile?(file)
      if File.file?(file)
        DATAFILE == File.basename(file).downcase
      else
        false
      end
    end
    module_function :datafile?

    # path �̒����Ƀf�[�^�t�@�C��������ΐ^��Ԃ��B
    def datafile_exist?(path)
      files = Dir.entries(path).delete_if{|f| !File.file?(File.join(path, f))}
      files.member?(DATAFILE)
    end
    module_function :datafile_exist?

    # path �̒����Ƀf�[�^�t�@�C��������΂��̃t�@�C������Ԃ��B
    # �f�[�^�t�@�C�����Ȃ���΁Cnil ��Ԃ��B
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

      # LazyAlbum::Entry�I�u�W�F�N�g�𐶐�����B
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

      # �f�[�^�t�@�C���������ǂݍ��݁C���g��Ԃ��B
      def read
        datafilename = LazyAlbum.datafile(@path)
        raise NoDataFileError unless datafilename   # �f�[�^�t�@�C�����Ȃ���Η�O����
        @data = YAML.load_file(datafilename)
        @attributes = @data["attributes"]
        @title = @attributes["title"]
        @datafile = File.basename(datafilename)
        self
      end

      # @path �ȉ��̃f�B���N�g�����������A�G���g����ǉ�����B
      # ���g��Ԃ��B
      def search
        @sub_entries = LazyAlbum::Entries.new(@entry_path).serch
      end

      # �G���g���Ɋ܂܂��摜�t�@�C�����̔z���Ԃ��B
      def pictures
        files = Dir.glob("#{@path}/*")
        files = files.delete_if{|f| !LazyAlbum.picture?(f)}
        files = files.collect{|f| File.basename(f)}
        files
      end

      # �T���l�C���f�B���N�g�������B
      def make_thumb_dir
        thumb_dir = File.join(@path, THUMB_DIR_NAME)
        Dir.mkdir(thumb_dir)
        thumb_dir
      end

      # �T���l�C�������B
      def make_thumbnail_all
        thumb_dir = File.join(@path, THUMB_DIR_NAME)
        make_thumb_dir unless File.exist?(thumb_dir)
        pictures.each do |pic|
          thumb = File.join(thumb_dir, "tn_#{pic}")
          unless File.exists?(thumb)
            geometry = Magick::Geometry.from_s("150x150")
            img = Magick::Image.read("#{@path}/#{pic}").first
            thumbnail = img.change_geometry(geometry) do |cols, rows, i|
              i.resize!(cols, rows)
            end
            thumbnail.write(thumb)
          end
        end
      end

    end    # class LazyAlbum::Entry


    class Entries

      # LazyAlbum::Entries�I�u�W�F�N�g�𐶐�����B@base_path �ȊO�͋�B
      def initialize(entry_path = "")
        @config = Config.instance
        @base_path = File.expand_path(@config.data_dir)
        @entry_path = entry_path
        @path = File.join(@base_path, @entry_path)
        @entries = []
      end

      attr_reader :base_path, :entry_path

      # @base_path �ȉ��̃f�B���N�g�����������A�G���g����ǉ�����B
      # ���g��Ԃ��B
      def serch
        Dir.glob(File.join(@path, "*")) do |f|
          next if /^\./ =~ File.basename(f)
          # �摜�t�@�C���݂̍�f�B���N�g����ΏۂƂ���B
#          if File.directory?(f) and LazyAlbum.picture_exist?(f)
          if File.directory?(f)
            entry = LazyAlbum::Entry.new(File.join(@entry_path, File.basename(f)))
            # �����f�[�^�t�@�C�����݂�΁C�����ǂݍ��ށB
            entry.read if LazyAlbum.datafile_exist?(f)
            @entries << entry
          end
        end
        self
      end

      # entry�iLazyAlbum::Entry�I�u�W�F�N�g�j��ǉ�����B
      def add(entry); @entries << entry; end
      alias :<< :add

      # �e�G���g���ɑ΂��ău���b�N���J��Ԃ��C�e���[�^�B
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

      # �G���g�����Ȃ���ΐ^��Ԃ��B
      def empty?
        @entries.empty?
      end

    end    # class LazyAlbum::Entries

end    # of module LazyAlbum

