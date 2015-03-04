require 'vigilem/support/transmutable_hash'

require 'vigilem/support/utils'

require 'vigilem/support/metadata'

require 'vigilem/support/key_map_info'

module Vigilem
module Support
  # 
  # 
  # a TransmutableHash representing a keyboard map
  # keymap = system, KeyMap ruby object
  # @see http://kbd-project.org/manpages/man5/keymaps.5.html
  # @see man dumpkeys -f
  # @todo to_file
  # @todo win32
  # @todo document the expected columns
  # @todo default for each key default_proc point
  # @todo move to a parser object
  # @todo update to fit Win32#LoadKeyboardLayout
  # @todo eject os specific, and make them loadable/injectable
  # @todo some methods return Hash instead of KeyMap
  class KeyMap < TransmutableHash
    
    # starts with keycode | spaces or '='
    KEYCODE_SPLIT_REGEX = /(keycode\s+\d{1,3})|\s(=)?\s?/
    
    include Metadata
    
    attr_writer :mod_weights, :short_inspect, :info
    attr_accessor :charset
    
    # 
    # @param  [Hash] init_hash_or_default the initial hash or default value
    # @param  default_value, the default value if not given in init_hash_or_default
    def initialize(init_hash_or_default={}, default_value=nil)
      if init_hash_or_default.is_a? Hash
        super(init_hash_or_default, default_value)
      else
        super({}, init_hash_or_default)
      end
    end
    
    # 
    # @return [KeyMap]
    def each(&block)
      self.class[super(&block)]
    end
    
    # 
    # @return [KeyMap]
    def select(&block)
      self.class[super(&block)]
    end
    
    # @todo   overwrite from info or move to info
    # @return [Hash]
    def mod_weights
      if self.class.mod_weights != @mod_weights
        @mod_weights = self.class.mod_weights.merge(@mod_weights)
      else
        @mod_weights
      end
    end
    
    # I.E. keymaps 0-2,4-5,8,12 
    # @return [Array<Range || Integer>] the parsed keymap spec
    def spec
      @spec ||= []
    end
    
    # 
    # @param  [String || NilClass] str, defaults to nil
    # @return [NilClass || KeyMapInfo] 
    def info(str=nil)
      if str
        @info = KeyMapInfo.load_string(str)
      else
        @info
      end
    end
    
    # gets the left_side from the right_side_values
    # @param  right_side_values
    # @return right_side_values or w/e the left_side it is mapped to
    def left_side(right_side_values=nil)
      if right_side_values
        if inverted? 
          self[right_side_values]
        else
          invert[right_side_values]
        end
      else
        inverted? ? self.values : self.keys
      end
    end
    
    # 
    # @param  [Array<Symbol>] method_names
    # @return [Proc]
    def left_side_aliases(*method_names)
      method_names.each do |method_name|
        define_singleton_method(method_name) {|right_side_value=nil| self.left_side(right_side_value) }
      end
    end
    
    alias_method :left_side_alias, :left_side_aliases
    
    # keycode keynumber = keysym keysym keysym...
    # modsym modsym modsym keycode keynumber = keysym keysym keysym...
    # get the right_side from the left_side_values
    # @param  left_side_values
    # @return 
    def right_side(left_side_values=nil)
      if left_side_values
        if inverted? 
          invert[left_side_values]
        else
          self[left_side_values]
        end
      else
        inverted? ? self.keys : self.values
      end
    end
    
    # essentially an alias_method
    # @param  [Symbol] method_names
    # @return [Proc]
    def right_side_aliases(*method_names)
      method_names.each do |method_name|
        define_singleton_method(method_name) {|left_side_values=nil| self.right_side(left_side_values) }
      end
    end
    
    alias_method :right_side_alias, :right_side_aliases
    
    # @see    TransmutableHash#invert
    # @return [KeyMap]
    def invert
      self.class[super]
    end
    
    #=== @todo move to parser
    
    # takes keycode expresssion blocks and adds them to this KeyMap
    # @param  [Array<String>] expresssion_blocks array of ["keycode = vvv", "keycode = vvvv", "alt keycode = vvvv"]
    # @return [nil] 
    def parse_keymap_expressions(*expresssion_blocks)
      expresssion_blocks.each {|expr_block| parse_expression_block(expr_block) }.compact
      nil
    end
    
    # @todo   cleanup
    # takes a keycode expresssion block and adds them to this KeyMap
    # dumpkeys -f || cached.kmap.gz
    # @param  [String] expr_blk a String block from keycode to next keycode
    # @return [NilCLass]
    def parse_expression_block(expr_blk)
      expr_blk.split("\n").map do |line|
        # skip comments
        unless line.split('#').first.to_s.empty?
          if line =~ /^keymaps/
            parse_keymap_spec(line)
          else
            line_ary = line.to_s.split(KEYCODE_SPLIT_REGEX).reject(&:empty?)
            if eq_index = line_ary.index('=')
              # ["keycode   2",  "=", "U+0031", "U+0021", "U+0031", "U+0031", "VoidSymbol",... ]
              _parse_sides(*Utils.split_on(line_ary, eq_index))
            end #if eq_index
          end #if line
        end #unless
      end #expr
      nil
    end
    
    # 
    # @param  [String] left_side
    # @param  [String] right_side
    # @return 
    def _parse_sides(left_side, right_side)
      #["alt", "keycode   2"]
      keycode = left_side.pop.gsub(/\s+/, '')
      if left_side.size > 0
        self[Utils.unwrap_ary([*left_side, keycode].flatten)] = Utils.unwrap_ary(right_side)
      else
        build_hash_from_full_table_line(right_side, keycode)
      end
    end
    
    private :_parse_sides
    
    # takes a list of keysyms configures thier modifiers and adds them to this keymap
    # @see    ::build_hash_from_full_table_line
    # @param  [Array<String>] right_side an array of keysyms, in a full table this is the right side
    # @param  [String] keycode the keycode in that is being mapped
    # @return [TransmutableHash] the results of 
    def build_hash_from_full_table_line(right_side, keycode)
      raise 'keymap specification missing' if spec.empty?
      merge!(self.class.build_hash_from_full_table_line(right_side, keycode, spec))
    end
    
    # converts keymap spec to ranged array
    # @param  [String] expr 'keymaps 0-127' or 'keymaps ?-?,?'
    # @return [Array<Range|| Integer>] the parsed keymap spec that
    def parse_keymap_spec(expr)
      @spec = expr.split(/\s|,/)[1..-1].map {|str| str =~ /\-/ ? Range.new(*str.split('-').map(&:to_i)) : str.to_i }
    end
    
    # tests whether or not num is in the spec
    # @param  [Numeric] num is this number within 'keymaps 0-127' or 'keymaps ?-?,?'
    # @return [TrueClass || FalseClass]
    def in_spec?(num)
      Utils.in_ranged_array?(spec, num)
    end
    
    class << self
      
      # weights of the modifiers set by `keymaps`
      def mod_weights 
        @mod_weights ||= { 'shift' => 1, 
          'altgr' => 2, 'control' => 4, 
          'alt' => 8, 'shiftl' => 16, 
          'shiftr' => 32, 'ctrll' => 64, 
          'ctrlr' => 128, 'capsshift' => 256 }
      end
      
      alias_method :columns, :mod_weights
      
      # converts a a keymap file to a ruby object
      # @todo   change to stream reading
      # @param  [String] path the path of the File
      # @return [KeyMap] the String as a Ruby object
      def load_file(path)
        load_string(File.binread(path))
      end
      
      # loads a keymap string and converts it to a Ruby object
      # @param  [String] str string to convert to KeyMap
      # @return [KeyMap] the String as a Ruby object
      def load_string(str, str_info=nil)
        exprs = str.split(/^keycode/)
        inst = self.new()
        inst.parse_keymap_expressions(exprs[0], *exprs[1..-1].map {|exp| "keycode#{exp}" })
        inst.info(KeyMapInfo.load_string(str_info)) if str_info
        inst
      end
      
      # takes a list of keysyms and converts it to a TransmutableHash
      # @todo   name change?
      # @param  [Array<String>] right_side an array of keysyms, in a full table this is the right side
      # @param  [String] keycode the keycode in that is being mapped
      # @param  [Array<Numeric||Range>] columns
      # @return [TransmutableHash] of the keycode combinations mapped to keysyms
      def build_hash_from_full_table_line(right_side, keycode, columns=[0..127])
        raise 'cannot build expresssions for full table with no columns' if columns.empty?
        sze = right_side.size
        right_side.each_with_object(TransmutableHash.new).with_index do |(keysyms, hsh), idx|
          if Utils.in_ranged_array?(columns, idx) 
            # not sure why a 'b' is in the mapping when that's not an available range
            (flat = [keysyms].flatten).last.gsub!(/^\+?0x0b/, '0x00') 
            hsh[Utils.unwrap_ary([mod_combin(idx), keycode].flatten)] = Utils.unwrap_ary(flat)
          end
        end
      end
      
      # finds the Combination (without repeats) of modifiers that fit into n
      # @param  [Integer] n the number to fit the modifiers into
      # @return [Array<String>] 
      def modifier_combination(n)
        mod_weights.map {|name, weight| name if weight & n != 0 }.compact
      end
      
      alias_method :mod_combin, :modifier_combination
      
    end
    
    # 
    # @return [TrueClass || FalseClass]
    def short_inspect?
      !!@short_inspect
    end
    
    # 
    # @return [TrueClass || FalseClass]
    def short_inspect!
      self.short_inpsect = true
    end
    
    # 
    # @return [String]
    def short_inspect
      num = (not @short_inspect.is_a?(Integer)) ? 30 : @short_inspect
      "#{Hash[self.to_a.sample(num)].inspect.chomp('}')}...snip...@metadata.keys=#{metadata.keys}}"
    end
    
    # 
    # @return [String]
    def inspect
      if short_inspect?
        short_inspect
      else
        super
      end
    end
    
    # 
    # @param  [Symbol] method_name
    # @param  [Array] args
    # @param  [Proc] block
    # @return 
    def method_missing(method_name, *args, &block)
      if self.keys.include? method_name
        self[method_name]
      else
        super(method_name, *args, &block)
      end
    end
    
  end
end
end
