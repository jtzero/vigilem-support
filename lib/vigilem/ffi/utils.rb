require 'vigilem/support/core_ext'

module Vigilem
module FFI
  # utilities for FFI
  module Utils
  
    # converts struct to a Hash
    # @note   this will chow through unions and 
    #         Hash all of thier members
    # @param  [#members, #values] struct
    # @param  [Integer || NilClass] limit
    # @return [Hash]
    def struct_to_h(struct, limit=nil)
      Utils._struct_to_h(struct, 1, limit)
    end
    
    # gets the FFI::Type::Builtin a type
    # @param  [Symbol || ::FFI::Type::Builtin] type
    # @return [Symbol] the builtin type name
    def get_builtin_type_name(type)
      builtin = ::FFI.find_type(type) || type
      raise TypeError, "unable to resolve type '#{type}'" unless builtin.is_a? ::FFI::Type::Builtin
      (nt = ::FFI::NativeType).constants.find {|const| nt.const_get(const) == builtin }.downcase
    end
    
    alias_method :get_native_type_name, :get_builtin_type_name
    
    # @todo this is a problem, like XOpenDisplay, the ptr returned
    # maybe huge, but that;s not the size of the object in the pointer
    # @param  [Pointer] pointer
    # @return [Integer]
    def ptr_capacity(pointer)
      pointer.size/pointer.type_size
    end
    
    # 
    # @param  [FFI::Pointer] pointer
    # @param  [Integer] offset, defaults to `0'
    # @param  [Integer] len, defaults to `nil'
    # @return [TrueClass || FalseClass] whether or not the pointer content is #clear
    def clear?(pointer, offset=0, len=nil)
      byts = pointer.get_bytes(offset, (len || ptr_size = (pointer.size - offset)))
      byts.eql?("\x00" * (len || ptr_size))
    end
    
    # 
    # @param  [#type] obj
    # @return [TrueClass || FalseClass]
    def is_a_struct?(obj)
      [::FFI::Struct, ::FFI::StructByValue, ::FFI::StructByReference].any? {|struct_klass| obj.is_a?(struct_klass) or obj.respond(:type).is_a? struct_klass }
    end
    
    # 
    # @param  [::FFI::Pointer] pointer
    # @param  [Symbol || ::FFI::Type::Builtin] type
    # @param  value
    # @return [::FFI::Pointer] pointer
    def write_typedef(pointer, type, value)
      pointer.__send__(:"write_#{get_builtin_type_name(type) }", value)
    end
    
    # 
    # @param  [::FFI::Pointer] pointer
    # @param  [Class] struct_class
    # @param  [Integer] num
    # @return [Array]
    def read_array_of_structs(pointer, struct_class, num=nil)
      1.upto(num||pointer.type_size/struct_class.size).map { struct_class.new(pointer) }
    end
    
    # 
    # possible refactor `pointer.write_array_of_type(type, :"write_array_of_#{get_builtin_type_name(type) }", [*value])`
    # @param  [::FFI::Pointer] pointer
    # @param  [Symbol || ::FFI::Type::Builtin] type
    # @param  [Array] value
    # @return [::FFI::Pointer] pointer
    def write_array_typedef(pointer, type, value)
      pointer.__send__(:"write_array_of_#{get_builtin_type_name(type) }", [*value])
    end
    
    # 
    # @param  [::FFI::Pointer] pointer
    # @param  [Symbol || ::FFI::Type::Builtin] type
    # @return value from pointer
    def read_typedef(pointer, type)
      pointer.__send__(:"read_#{get_builtin_type_name(type) }")
    end
    
    # 
    # @param  [::FFI::Pointer] pointer
    # @param  [Symbol || ::FFI::Type::Builtin] type
    # @param  [Integer] num
    # @return [Array]
    def read_array_typedef(pointer, type, num=1)
      pointer.__send__(:"read_array_of_#{get_builtin_type_name(type) }", num)
    end
    
    # 
    # @param  [::FFI::Pointer] pointer
    # @param  [String] type
    # @param  value
    # @param  [Integer] offset
    # @return [::FFI::Pointer] pointer
    def put_typedef(pointer, type, value, offset=0)
      pointer.__send__(:"put_#{get_builtin_type_name(type) }", offset, value)
    end
    
    # 
    # @param  [::FFI::Pointer] pointer
    # @param  [String] type
    # @param  [Array] value
    # @param  [Integer] offset
    # @return pointer
    def put_array_typedef(pointer, type, value, offset=0)
      pointer.__send__(:"put_array_of_#{get_builtin_type_name(type) }", offset, [*value])
    end
    
    # 
    # @param  [::FFI::Pointer] pointer
    # @param  [Symbol || ::FFI::Type::Builtin] type
    # @param  value
    # @return [::FFI::Pointer] pointer
    def replace_typedef(pointer, type, value)
      put_typedef(pointer, type, value)
    end
    
    # 
    # @param  [::FFI::Pointer] pointer
    # @param  [Symbol || ::FFI::Type::Builtin] type
    # @param  value
    # @return pointer
    def add_int_typedef(pointer, type, value)
      replace_typedef(pointer, type, (value + self.read_typedef(pointer, type)))
    end
    
    # shorthand for #class.layout.fields, can handle as an object
    # instead of just a struct.class
    # @param  [#layout] struct_obj_or_class
    # @param  [Proc] block
    # @return [Array<FFI::StructLayout::Field>]
    def fields(struct_obj_or_class)
      struct_class = unless struct_obj_or_class.respond_to? :layout
                 Support::Utils.get_class(struct_obj_or_class)
              else
                struct_obj_or_class
              end
      struct_class.layout.fields
    end
    
    # @todo   refactor me
    # assigns values to the struct_or_union
    # @param  [::FFI::Struct] struct_or_union
    # @param  [Array || Hash] vals
    # @return struct_or_union
    def struct_bulk_assign(struct_or_union, vals)
      if vals.is_a? Hash
        self.struct_bulk_assign_hash(struct_or_union, vals)
      else
        if struct_or_union.is_a? ::FFI::Union and (not vals.is_a? Hash)
          raise ArgumentError, "`#{vals.inspect}' cannot be assigned to Union `#{struct_or_union.inspect}', a Hash is needed to decide which union attr to assign to"
        end
        fields(struct_or_union).map do |fld|
          _struct_bulk_assign(struct_or_union, fld, fld.name, vals)
        end
      end
      struct_or_union
    end
    
    alias_method :from_array, :struct_bulk_assign
    
    # @todo   refactor me
    # @param  [::FFI::Struct] struct_or_union
    # @param  [Hash] hsh
    # @return struct_or_union
    def struct_bulk_assign_hash(struct_or_union, hsh)
      hsh.each do |key, value|
        attributes = fields(struct_or_union)
        the_field = attributes.find {|fld| fld.name == key }
        raise "on #{struct_or_union.class} attr #{key} not found in #{attributes.map(&:name)}" unless the_field
        _struct_bulk_assign(struct_or_union, the_field, key, [hsh[key]])
      end
      struct_or_union
    end
    
    alias_method :from_hash, :struct_bulk_assign_hash
    
    # @todo   refactor me
    # @param  [::FFI::Struct] struct
    # @param  [::FFI::StructLayout::Field] field
    # @param  [Symbol] attr_name
    # @param  [Array || Hash] vals
    # @return 
    def _struct_bulk_assign(struct_or_union, field, attr_name, vals)
      type = field.type
      if is_a_struct?(field) and not (is_a_struct?(frst = vals.first) or frst.is_a? ::FFI::Union)
        ptr_offset = struct_or_union.offsets.assoc(attr_name).last
        struct_obj = type.struct_class.new(struct_or_union.to_ptr.slice(ptr_offset, type.size))
        struct_or_union[attr_name] = struct_bulk_assign(struct_obj, vals.shift)
      else
        raise ArgumentError, "Arity mismatch: `#{vals.inspect}' cannot be asigned to complex type `#{struct_or_union.inspect}'" unless vals.respond_to? :shift
        struct_or_union[attr_name] = vals.shift
      end
    end
    
    # 
    # @param  [Class] struct_class
    # @param  [String] str_bytes
    # @return [Array<FFI::Struct>] 
    def bytes_to_structs(struct_class, str_bytes)
      ary_of_type(struct_class, struct_class.size, ::FFI::MemoryPointer.from_string(str_bytes))
    end
    
    # converts a pointer to an ary of ary_type
    # @param  type
    # @param  [Fixnum] type_size, this is given because a ::from_string has type_size of 1
    # @param  [FFI::Pointer] pointer
    # @return [Array] of type
    def ary_of_type(type, type_size, pointer, len=-1)
      if type.is_a? Class and type <= ::FFI::Struct
        # slice returns a new pointer at that memory location, so both pointers point, to that location
        0.upto((pointer.size/type_size) - 1).map {|n| type.new(pointer.slice(n * type_size, type_size).dup) }
      else
        ::Vigilem::FFI::Utils.read_array_typedef(pointer, type, ptr_capacity(pointer))
      end
    end
    
    # @todo 
    #def ary_of_type!
    #end
    
    extend self
    
   module_function
    # 
    # @param  [#members, #values] struct
    # @param  [Integer || NilClass] limit
    # @return [Hash || Struct]
    def _struct_to_h(struct, current=1, limit=nil)
      if limit.nil? or limit <= current
        Hash[struct.members.zip(struct.values.map do |val| 
          if is_a_struct?(val) or val.is_a?(::FFI::Union)
            _struct_to_h(val, current + 1, limit)
          else
            val 
          end
        end)]
      else
        struct
      end
    end
    
  end
end
end

require 'vigilem/ffi/utils/struct'
