require 'vigilem/support/core_ext'

module Vigilem
module Support
  # 
  # @todo 2 tables one for keysyms and the other for keycodes
  module ArrayAndStringUtils
    # splits an Array or String into parts at a 
    # location (rather than content) keeping the 
    # i-1 item in the lower "array"
    # @param  [#dup, #slice!] obj
    # @param  [Numeric] idx
    # @return [Array]
    def split_at(obj, idx)
      [(copy = _deep_dup(obj)).slice!(0...idx), copy]
    end
    
    # works like split where the item split
    # is removed
    # @see    #split_at
    # @param  [#dup, #slice!]
    # @param  [Numeric] idx
    # @return [Array]
    def split_on(obj, idx)
      [(copy = _deep_dup(obj)).slice!(0...idx), copy.slice!(1..-1)]
    end
    
    # \#slice!s the array the length, and returns what is left over
    # from the len `if len > obj.length`
    # @param  [#slice!, (#length || #size)] obj
    # @param  [Integer] len
    # @return [Array<Object, Integer>] [obj #slice!ed, remainder of (len - obj.size)]
    def offset!(obj, len)                                #@todo V should be nil not ''
      [_offset_from_length(obj, len), (obj.slice!(0..len-1) || '')].reverse
    end
    
    # @see #offset! 
    # @param  [#dup, #slice!, #length] obj
    # @param  [Integer] len
    # @return [Array<Object, Integer>] [obj #slice!ed, remainder of (len - obj.size)]
    def offset(obj, len)
      if obj.respond_to? :slice   #@todo V should be nil not ''
        sliced = (obj.slice(0..len-1) || '')
        [sliced, _offset_from_length(obj, len)]
      else
        offset!(_deep_dup(obj), len)
      end
    end
    
    # if the Array contains one item it #pop's it off
    # otherwise returns the array
    # @param  [Array] ary 
    # @return [Object || Array] [contents of array || the array unchanged
    def unwrap_ary(ary)
      (ary.respond_to?(:pop) and ary.one?) ? ary.pop : ary
    end
    
    # takes an Array with Ranges inside and checks to see if 
    # the number falls within that or matches one of the Integers passed it
    # @param  [Array<Numeric||Range>] ranged_ary the array to check
    # @param  [Numeric] num the number to check
    # @return [TrueClass || FalseClass] whethor or not it is in or within that array
    def in_ranged_array?(ranged_ary, num)
      !!ranged_ary.find {|n| n === num }
    end
  end
  
  # 
  # 
  module NumericUtils
    # ceiling division
    # @param  [Integer] num numerator
    # @param  [Integer] denom denominator
    # @return [Integer]
    def ceil_div(num, denom)
      (num.to_f/denom).ceil
    end
    
    # Computes the value of the first specified argument 
    # clamped to a range defined by the second argument
    # @param  [Numeric] x the number check against
    # @param  [Hash] min_or_max
    # @option min_or_max [Numeric] :min lower bounds
    # @option min_or_max [Numeric] :max upper bounds
    # @return [Numeric] the clamped number
    def clamp(x , min_or_max={})
      [[x, min_or_max[:max]].compact.min, min_or_max[:min]].compact.max
    end
  end
  
  # 
  # 
  module GemUtils
    class << self
      
      #
      # @return [String] directory of the data folder for this gem
      def data_dir(file_or_dir_path)
        "#{gem_path(file_or_dir_path)}#{File::SEPARATOR}data"
      end
      
      # 
      # @return [String]
      def gem_path(file_or_dir_path)
        gem_root = Gem.path.find_result do |path|
          regex = %r<(#{path})(#{File::SEPARATOR}gems#{File::SEPARATOR})>
          if file_or_dir_path =~ regex
            paths = file_or_dir_path.split(regex).reject(&:empty?)
            if paths.size > 2
              "#{paths[0]}#{paths[1]}#{paths[2].split('/', 2).first}"
            end
          end
        end
        if gem_root
          gem_root
        else
          require 'bundler'
          Bundler.root.to_path
        end
      end
      
    end
    
  end
  
  # 
  # 
  module KernelUtils
    # @todo   change name?
    # gets the class if an object
    # and returns self if already a Class
    # @param  obj object to get Class from
    # @return [Class]
    def get_class(obj)
      obj.is_a?(Class) ? obj : obj.class
    end
    
    # sends all the args given to it, or none based on #arity the method object passed in
    # this works great for sending arguments to a list of procs
    # @param  [#call] method_or_proc
    # @param  [Array] args
    # @param  [Proc] block
    # @return 
    def send_all_or_no_args(callable, *args, &block)
      callable.call(*[nil, args][clamp(callable.arity, min: 0, max: 1)], &block)
    end
  end
  
  # 
  # 
  module ObjectUtils
    # checks if object responds to deep_dup first
    # :deep_dup, :_dump :_dump_data
    # @todo name change
    # @param  obj
    # @return 
    def _deep_dup(obj)
      if obj.respond_to?(:deep_dup) and
          not method(:deep_dup).source_location.first =~ /activesupport/
        obj.deep_dup
      else
        deep_dup(obj)
      end
    end
    
    # :deep_dup, :_dump :_dump_data
    # @param obj
    def deep_dup(obj)
      Marshal.load(Marshal.dump(obj))
    end
    
    # emulates the id in inspect
    # @param  [#object_id]
    # @return [String] 
    def inspect_id(obj)
      @padding_size ||= Object.new.inspect.split(':0x').last.chomp('>').length
      "0x%0#{@padding_size}x" % (obj.object_id << 1)
    end
    
    # @todo   test
    # @param  
    # @param  [Proc] block
    # @yields [' ', instance variable name, '=', instance variable value]
    # @return [Array], [['#<', object class, ':', object "value space id"], instance variables prefixed by ' ' and split by '=', ['>']]
    def inspect_shell(obj, &block)
      [['#<', obj.class, ':', inspect_id(obj)], obj.instance_variables.map.with_index do |var_name, i| 
        if i == 0
          ary = [' ', var_name, '=', obj.instance_variable_get(var_name)] 
        else
          ary = [', ', var_name, '=', obj.instance_variable_get(var_name)]
        end
        yield *ary if block_given?
        ary
      end, ['>']]
    end
  end
  
  # 
  # simple utils/standard lib type stuff
  module Utils
    
    include ArrayAndStringUtils
    
    include NumericUtils
    
    include GemUtils
    
    include KernelUtils
    
    include ObjectUtils
    
    extend self
    
   module_function
    
    # 
    # @param  [#size || #length] obj
    # @param  [Integer] num
    # @return [Integer || nil] remainder of num if available
    def _offset_from_length(obj, num)
      if obj.respond_to?(:length) || obj.respond_to?(:size)
        clamp(num - (obj.respond(:length) || obj.respond(:size)), min: 0)
      end
    end
    
  end
  
  extend Support::GemUtils
end
end
