module Vigilem
module FFI
module Utils
  # Utils specfic to Vigilem::FFI::Struct
  module Struct
    
    extend ActiveSupport::Concern
    
    # methods to be ::extend'd
    module ClassMethods
      
      # converts the members of the struct to methods
      # @return 
      def members_to_methods
        members.each do |member_name| 
          define_method(member_name, &lambda { self[member_name] })
          define_method(:"#{member_name}=", &lambda {|val| self[member_name] = val })
        end
      end
      
      # @see    FFI::Struct::layout
      # @param  [Array] args
      # @return 
      def layout_with_methods(*args)
        raise SizeError, "Odd number of aguments:`#{args}'" if args.size.odd?
        aliases = []
        layout *(args.map do |names_or_value| 
          if names_or_value.is_a? Array
            aliases << names_or_value
            names_or_value.first
          else
            names_or_value
          end
        end)
        ret = members_to_methods
        aliases.each {|name_group| name_group.each {|alias_name| alias_method(alias_name, name_group[0]) } }
        ret
      end
      
      # @todo   update the layout without overwriting, when called after layout
      # acts "like" the union keyword
      # @return 
      def union(name, *args, &block)
                # can't be Ruby Struct, because of layout_with_methods
        unyun = Class.new(::FFI::Union) do
          include Vigilem::FFI::Utils::Struct
          layout_with_methods *(args.empty? ? block.call : args)
        end
        const_set(:"#{name[0].upcase}#{name[1..-1]}", unyun)
        [name.to_sym, unyun]
      end
      
      # 
      # @param  [String] str_bytes
      # @return [Array<VFFIStruct>]
      def from_string(str_bytes)
        Utils.bytes_to_structs(self, str_bytes)
      end
    end
      
    # @see    FFI::Utils#bulk_assign
    # @param  [Hash || Array] vals
    # @return 
    def bulk_assign(vals)
      ::Vigilem::FFI::Utils.struct_bulk_assign(self, vals)
    end
    
    # 
    # @param  [Symbol] attr_name
    # @return 
    def type_of(attr_name)
      field = self.class.layout.fields.find {|fld| fld.name == attr_name }
      raise "no field by the name #{attr_name} for #{self}" unless field
      field.type
    end
    
    # 
    # @param  [Proc] block
    # @return 
    def types(&block)
      ::Vigilem::FFI::Utils.types(self, &block)
    end
    
    # 
    # @see    Vigilem::FFI::Utils.struct_to_h
    # @return [Hash]
    def to_h
      ::Vigilem::FFI::Utils.struct_to_h(self)
    end
  end
end
end
end
