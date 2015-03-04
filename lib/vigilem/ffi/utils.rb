module Vigilem
module FFI
  # utilities for FFI
  module Utils
  
    # converts struct to a Hash
    # @param  [#members, #values] struct
    # @param  [Integer || NilClass] limit
    # @return [Hash]
    def struct_to_h(struct, limit=nil)
      Utils._struct_to_h(struct, limit)
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
    
    # @todo needed?
    # @param  struct
    # @param  [Proc] block
    # @return the type of the fields or the result of the block
    def types(struct, &block)
      struct = Support::Utils.get_class(struct) unless struct.respond_to? :layout
      struct.layout.fields.map do |field|
        if block
          yield field
        else
          field.type
        end
      end
    end
    
    # @todo   refactor me
    # assigns values to the struct
    # @param  [::FFI::Struct] struct
    # @param  [Array || Hash] vals
    # @return struct
    def struct_bulk_assign(struct, vals)
      if vals.is_a? Hash
        self.struct_bulk_assign_hash(struct, vals)
      else
        types(struct) do |fld|
          _struct_bulk_assign(struct, fld, fld.name, vals)
        end
      end
      struct
    end
    
    alias_method :from_array, :struct_bulk_assign
    
    # 
    # @param  [::FFI::Struct] struct
    # @param  [Hash] hsh
    # @return struct
    def struct_bulk_assign_hash(struct, hsh)
      hsh.each do |key, value|
        the_field = struct.layout.fields.find {|fld| fld.name == key }
        raise "on #{struct.class} attr #{key} not found in #{struct.layout.fields.map(&:name)}" unless the_field
        _struct_bulk_assign(struct, the_field, key, [hsh[key]])
      end
      struct
    end
    
    alias_method :from_hash, :struct_bulk_assign_hash
    
    # @todo   unions don't need know the member name, the space taken up is the same
    # @todo   refactor me
    # @param  [::FFI::Struct] struct
    # @param  [::FFI::StructLayout::Field] field
    # @param  [Symbol] attr_name
    # @param  [Array || Hash] vals
    # @return 
    def _struct_bulk_assign(struct, field, attr_name, vals)
      # struct.type.struct_class, why use field?
      #if is_a_struct?(struct.type)
      if is_a_struct?(field)
        if is_a_struct?(frst = vals.first) or frst.is_a? ::FFI::Union
          struct[attr_name] = vals.shift
        else
          ptr_offset = struct.offsets.assoc(attr_name).last
          struct_obj = if (struct_klass = field.type.struct_class) <= VFFIStruct
                        struct_klass.new(ptr_offset)
                      else
                        struct_klass.new
                      end
          struct[attr_name] = struct_bulk_assign(struct_obj, vals.shift)
        end
      else
        raise ArgumentError, "Arity mismatch: complex type `#{struct.inspect}' does not match argument `#{vals.inspect}'" unless vals.respond_to? :shift
        struct[attr_name] = vals.shift
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
        # @todo slice is supposed to return new a pointer, when atype.type_size == pointer.type_size does this return the old pointer?
        0.upto((pointer.size/type_size) - 1).map {|n| type.new(pointer.slice(n * type_size, type_size).dup) }
      else
        ::Vigilem::FFI::Utils.read_array_typedef(pointer, type, ptr_capacity(pointer))
      end
    end
    
    extend self
    
   module_function
    # 
    # @param  [#members, #values] struct
    # @param  [Integer || NilClass] limit
    # @return [Hash || Struct]
    def _struct_to_h(struct, current=1, limit=nil)
      if limit.nil? or limit <= current
        Hash[struct.members.zip(struct.values.map {|val| is_a_struct?(val) ? _struct_to_h(val) : val } )]
      else
        struct
      end
    end
    
  end
end
end

require 'vigilem/ffi/utils/struct'
