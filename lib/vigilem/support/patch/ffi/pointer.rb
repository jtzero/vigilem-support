require 'ffi'
require 'ffi/pointer'

module FFI
  class Pointer
    def ==(other_obj)
      return true if self.eql?(other_obj)
      if other_obj.respond_to? :bytes
        self.read_bytes(self.size) == other_obj.bytes
      elsif other_obj.respond_to? :read_bytes and 
                                      other_obj.respond_to? :size
        self.read_bytes(self.size) == other_obj.read_bytes(other_obj.size)
      else
        false
      end
    end
    
  end
end
