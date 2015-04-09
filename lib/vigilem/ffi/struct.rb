module Vigilem
module FFI
  # ::FFI::Struct with some sugar
  class Struct < ::FFI::Struct
    
    include Utils::Struct
    
    # 
    # @param [FFI::Pointer] pointer
    def initialize(pointer=nil)
      super(*pointer)
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
      self.to_ptr.get_bytes(0, self.size)
    end
    
    # 
    # @see    Utils#clear?
    # @return [TrueClass || FalseClass]
    def clear?
      Utils.clear?(self.to_ptr, 0, self.size)
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
