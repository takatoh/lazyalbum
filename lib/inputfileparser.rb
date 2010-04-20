#
# inputfileparser.rb
#
# $Id: inputfileparser.rb 20 2008-09-12 04:59:40Z 24711 $
#

    class InputFileError < StandardError; end


    # Input file scanner.
    #
    # === Sample code
    #
    #  inputfile = ARGV.shift
    #  keys = %w(name nubmer)
    #  separator = ":"
    #  scanner = InputFileScanner.new(keys, separator).scan(inputfile)
    #  inputdata = {}
    #  while pair = scanner.shift
    #    key, val = pair
    #    case key
    #    when 'name'
    #      inputdata[:name] = val.strip
    #    when 'number'
    #      inputdata[:number] = val.strip.to_i
    #    end
    #  end
    #
    class InputFileScanner

      # Returns an instance of BSL::Utils::InputFileScanner.
      #
      # The input file has lines separated key and value by separator(default is ':').
      # `keys' is an Array of String which means valid key.
      #
      def initialize(keys, separator = ":")
        @keys = keys
        @separator = separator.instance_of?(Regexp) ? separator : /#{separator}/
        @data = []
      end

      attr_reader :keys, :separator, :data

      # Returns the next pair of key and value.
      def shift
        @data.shift
      end

      # Scan input file.
      #
      #
      #
      def scan(input_file, listener = nil)
        @data = []
        f = File.open(input_file, "r")
        begin
        while line = f.gets
          while /\\$/ =~ line
            line = line.gsub(/\\$/, "") + f.gets
          end
          line = line.gsub(/\A\s*#.*$/, "")
          next if /\A *\Z/ =~ line
          if m = @separator.match(line)
            if @keys.member?(m.pre_match.strip)
              key = m.pre_match.strip
              val = m.post_match
            else
              raise InputFileError.new("Invalid key: #{m.pre_match.strip} : line #{f.lineno}")
            end
          else
            raise InputFileError.new("Wrong line: line #{f.lineno}")
          end
          @data << [key, val]
        end
        rescue InputFileError => error
          if listener
            listener << "#{error.message}\n"
            retry
          else
            raise
          end
        end
        f.close
        self
      end

    end    # of class BSL::Utils::InputFileScanner


    class EscapeFromLoop < InputFileError; end


    class InputFileParser

      def initialize(scanner, holder)
        @_scanner        = scanner
        @_holder         = holder
        @_actions        = []
        @_default_action = nil
        @__token         = nil
        @__key           = nil
        init
      end

      attr_reader   :_scanner, :_holder, :_actions, :default_action
      attr_accessor :__key
      attr_reader   :__token

      # Reads data.
      def read
        pre_loop
        loop
        post_loop
      end

      # Adds the pair of guide and action.
      def add_action(guide, &action)
        @_actions << [guide, action]
      end

      # Define default action.
      def def_default_action(&action)
        @_default_action = action
      end

      # Escapes from `loop' methods.
      # Pay attention to bypass `post_divide' method.
      def escape(message = nil)
        raise EscapeFromLoop.new(message)
      end


      ## Hook methods

      # To initialize instance.
      # Called at the end of `initialize' method.
      def init; end

      # Called before `loop' method.
      def pre_loop; end

      # Called before `divide' method (in `loop' method).
      def pre_divide; end

      # Called after `divide' method (in `loop' method).
      def post_divide; end

      # Called after `loop' method.
      def post_loop; end


      ## private methods.

      def loop
        @__token = nil
        @__key   = nil
        begin
          while @__token = @_scanner.shift
            @__key = @__token.dup
            pre_divide
            divide
            post_divide
          end
        resque EscapeFromLoop => efl
        end
      end
      private :loop

      def divide
        flg = false
        @_actions.each do |act|
          if act[0] === key
            act[1].call
            flg = true
            break
          end
        end
        unless flg
          @_default_action.call
        end
      end
      private :divide

    end    # of module BSL::Utils::InputFileParser


