module Vigilem
module FFI
  # ::FFI::Struct with some sugar
  class Struct < ::FFI::Struct
    
    include Utils::Struct
    
    # should make assign private, but since FFI::Struct.rb
    # doesn;t know it's memory location
    # this may have to be updated from the outside
    attr_accessor :ptr_offset
    
    # 
    # @param [FFI::Pointer || Integer] ptr_or_offset
    # @param [Integer] offset
    def initialize(ptr_or_offset=nil, offset=0)
      if ptr_or_offset.is_a? Integer
        super()
        @ptr_offset = ptr_or_offset
      else
        super(*ptr_or_offset)
        @ptr_offset = offset
      end
    end
    
    # allows initial values in a new object like Hash::[]
    # @todo   move to utils/struct::ClassMethods
    # @param  [Array<Hash||Array>] *vals
    # @return [Struct]
    def self.[](*vals)
      frst = vals.first
      vals = frst if frst.is_a? Hash and vals.size == 1
      new.bulk_assign(vals)
    end
        
    # converts struct to a String bytes "\x00" or "\u0000"
    # the struct needs to know where in the pointer it is...
    # @param  [FFI::Struct] struct
    # @return [String]
    def bytes
      ptr = self.to_ptr
      ptr.get_bytes(self.ptr_offset, self.size)
    end
    
    # shows the members and thier values in addition to the traditional inspect
    # @see    Object#inspect
    # @return [String]
    def inspect
      "#{super.chop} #{members.map {|mem| "#{mem}=#{self[mem]}" }.join(' ')}>"
    end
    
  end
end
end
