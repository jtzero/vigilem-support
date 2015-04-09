module Vigilem::FFI
  # creates an ary of fixed size that is synched with
  # an underlying FFI::Pointer, kind of reinventing the wheel here 
  # if you think about it
  # this can be split further for a more dynamic ary that can increase in
  # size, but thats for the future
  # @note ary is used to match ptr used by struct
  module ArrayPointerSync
    
    require 'vigilem/support/max_size_error'
    
    attr_accessor :cache_hash, :max_size
    
    # 
    # @raise  [TypeError] '@max_size is nil'
    # @return 
    def max_size!
      @max_size || raise(TypeError, '@max_size is nil')
    end
    
    alias_method :max_len, :max_size
    alias_method :max_len=, :max_size=
    
    private :cache_hash=, :max_size=, :max_len=
    
    # 
    # @return [FFI::Pointer]
    def ptr
      @ptr ||= FFI::MemoryPointer.new(self.class.ary_type, self.max_size!)
    end
    
    # 
    # @param  base
    # @return 
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        native_type FFI::Type::POINTER
      end
    end
    
    @point_cuts = (Array.instance_methods - 
                  [*Array.instance_methods.grep(/method|taint|trust|instance_variable|send|class|respond/),
                   :__id__, :object_id, :extend, :freeze, :kind_of?, :instance_of?, :is_a?, :replace, :eql?, :equal?
                  ]).sort
    
    # 
    # @param  [Symbol] method_name
    # @param  [Array] args
    # @param  [Proc] block
    # @raise  [RuntimeException] 
    # @see    #out_of_bounds_check
    # @return 
    def after_ary_method(method_name, return_value, *args, &block)
      out_of_bounds_check
      update
      return_value
    end
    
    @point_cuts.each do |point_cut|
      define_method(point_cut) do |*args, &block|
        begin
          update
          ret = ary().__send__(point_cut, *args, &block)
          method_name = __method__
          if not [:size, :length].include? method_name
            after_ary_method(method_name, ret, *args, &block)
          else
            ret
          end
        rescue StandardError => e
          e.set_backtrace([__method__.to_s] + e.backtrace)
          raise e
        end
      end
    end
    
    # @todo   change max_len_or_ptr_or_first_item, and default max_size to init_values.length
    # @param  [Integer || FFI::Pointer] max_len_or_ptr
    # @param  [Array] init_values
    # @return [ArrayPointerSync] self
    def initialize_ary_ptr_sync(max_len_or_ptr, *init_values)
      if max_len_or_ptr.is_a? FFI::Pointer
        if not (max_len_or_ptr and init_values.empty?)
          raise ArgumentError, "Cannot have both a pointer and *init_values:`#{max_len_or_ptr.inspect}' `#{init_values.inspect}'"
        end
        @ptr = max_len_or_ptr
        update_ary
        @max_size = ary().size
      else
        raise TypeError, "max_len_or_ptr, doesn't respond_to? :to_i" unless max_len_or_ptr.respond_to? :to_i
        @max_size = max_len_or_ptr.to_i
        @ary = init_values
        @ptr = ::FFI::MemoryPointer.new(self.class.ary_type, @max_size)
        update_ptr if not init_values.empty?
      end
      update_cache
      self
    end
    
    # 
    # 
    module ClassMethods
      include FFI::DataConverter
      
      # @todo   create and ary_type_wrapper for symbols so an if stmnt
      #         isn;t always needed
      # @raise  [RuntimeError] 
      # @return [Class || Symbol]
      def ary_type
        raise NotImplementedError, "No ary_type configured for this class #{self}"
      end
      
      # 
      # @return [Class]
      def ary_type_object
        if ary_type.is_a? Symbol
          ::FFI.find_type(ary_type)
        else
          ary_type
        end
      end
      
      # 
      # @return [Integer] the size
      def ary_type_size
        ary_type_object.size
      end
      
      # 
      # @param  [Pointer] pointer
      # @return [Integer]
      def ptr_capacity(pointer)
        pointer.size/ary_type_size
      end
      
      # 
      # @return [Array<#ary_type>]
      def ary_of_type(pointer)
        Utils.ary_of_type(ary_type, ary_type_size, pointer)
      end
      
      # @todo 
      # @return [Array<#ary_type>]
      #def ary_of_type!(pointer)
      #  Utils.ary_of_type!(ary_type, ary_type_size, pointer)
      #end
    end
    
    # @see    Array#replace
    # @param  [Array] other
    # @return [ArrayPointerSync]
    def replace(other)
      ary.replace(other)
      update
      self
    end
    # 
    # @return [String] 
    def bytes
      update
      ptr.read_bytes(ptr.size)
    end
    
    # bytes of the idtem referenced by index
    # @param  [Integer] idx
    # @return [String] 
    def bytes_of(idx)
      update
      ptr.get_bytes(idx * (type_size = self.class.ary_type_size), type_size)
    end
    
    # 
    # @return [Array<Integer>] 
    def offsets
      if update or @ptr_offsets.nil?
        _ptr_offsets
      else
        @ptr_offsets
      end
    end
    
    # 
    # @raise  [RuntimeError] when both ptr and ary changed
    # @return [Hash] what item changed
    def what_changed?
      results = {ary: ary_changed?, ptr: ptr_changed? }
      raise 'both ary and pointer changed' if results.values.all?
      results
    end
    
    # checks to see if the the ptr contents
    # or ary conents have changed
    # 
    # @return [TrueClass || FalseClass]
    def changed?
      what_changed?.values.any?
    end
    
    # 
    # @return [TrueClass || FalseClass]
    def ptr_changed?
      ptr_cache_hash() != ptr_hash()
    end
    
    # 
    # @return [TrueClass || FalseClass]
    def ary_changed?
      self.cache_hash != ary().hash
    end
    
    # checks whether or not ary.size > max_size
    # @return [TrueClass || FalseClass]
    def out_of_bounds?
      _size > max_size!
    end
    
    # 
    # @raises RuntimeException 
    # @return [NilClass]
    def out_of_bounds_check
      _raise_size_error if out_of_bounds?
    end
    
    # 
    # @param [Array] other
    # @return [ArrayPointerSync] 
    def replace(other)
      ary.replace(other)
      update
      self
    end
    
    # 
    # 
    # @return [Array] 
    def to_a
      update
      ary
    end
    
    # @todo
    #def to_ary
    #  
    #end
    
    # 
    # @return [ArrayPointerSync]
    def dup
      self.class.new(ptr.dup)
    end
    
    # dup copies everything to a new pointer, is this needed? does it copy 
    # @return [ArrayPointerSync]
    def deep_dup
      pointer = FFI::MemoryPointer.new(self.class.ary_type, max_size)
      pointer.write_bytes(self.bytes)
      self.class.new(pointer)
    end
    
    # @return [String] just like that of an array
    def to_s
      update
      ary.to_s
    end
    
    # 
    # @see    Object#inspect
    # @return [String] 
    def inspect
      update
      vars = instance_variables.except(:@ary).map {|var| "#{var}=#{instance_variable_get(var)}" }.join(' ')
      "#{_to_s.chomp('>')} #{vars}>"
    end
    
    # the basic inspect structure without the vars
    # @return [String]
    def _to_s
      "#<#{self.class}:0x#{object_id << 1} #{ary}>"
    end
    
   private
    attr_accessor :ptr_cache_hash
    
    # 
    # @return [Array] 
    def ary
      @ary ||= []
    end
    
    # 
    # @return [Array<Integer>]
    def _ptr_offsets
      @ptr_offsets = 0.upto((ary.size - 1)).map {|n| self.class.ary_type_size * n }
    end
    
    # @see    String#hash
    # @return [Integer] 
    def ptr_hash
      ptr.read_bytes(ptr.size).hash
    end
    
    # detects what changed and updates as needed
    # @return [TrueClass || FalseClass] updated?
    def update
      if (results = what_changed?)[:ary]
        update_ptr
        update_ary_cache
        true
      elsif results[:ptr]
        update_ary
        update_ptr_cache
        true
      else
        false
      end
    end
    
    # 
    # this is slightly dangerous, if anything was still pointing to old pointer location 
    # now its being reclaimed, this will change it
    # @return [Integer] hash
    def update_ptr
      ptr.clear
      if (not (arry_type = self.class.ary_type).is_a?(Symbol)) 
        if arry_type.respond_to? :to_native
          ary.each {|item| ptr.write_pointer(arry_type.to_native(item, nil)) }
        elsif arry_type.method_defined? :bytes
          ptr.write_bytes(ary.map {|item| item.respond.bytes }.join)
        elsif arry_type.method_defined? :pointer
          ary.each do |item|
            if item.size == item.pointer.size
              ptr.write_bytes((itm_ptr = item.pointer).read_bytes(itm_ptr.size))
            else
              raise ArgumentError, "Cannot reliably convert `#{item}' to a native_type"
            end
          end
        else
          raise ArgumentError, "Cannot reliably convert `#{arry_type}' to a native_type"
        end
      else
        Utils.put_array_typedef(ptr, arry_type, ary)
      end
      update_ptr_cache
      #self.ptr_cache_hash = @bytes.hash # @FIXME ptr_hash() and @bytes.hash should be the same...
    end
    
    # 
    # @return [Array<self.class.ary_type>]
    def update_ary
      arry = ary.replace(self.class.ary_of_type(ptr))
      _ptr_offsets
      update_ary_cache
      arry
    end
    
    # size method on ary without update
    # @return [Integer] size
    def _size
      ary.size
    end
    
    # 
    # @return [Array<Integer>]
    def update_cache
      [update_ary_cache, update_ptr_cache]
    end
    
    # 
    # @return [Integer] hash
    def update_ptr_cache
      self.ptr_cache_hash = ptr_hash()
    end
    
    # 
    # @return [Integer] hash
    def update_ary_cache
      self.cache_hash = ary().hash
    end
    
    # 
    # @raise  [RuntimeError]
    # @return 
    def _raise_size_error
      raise Vigilem::Support::MaxSizeError, [_to_s, self.max_size!]
    end
  end
end
