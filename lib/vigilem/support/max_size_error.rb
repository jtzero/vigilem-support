require 'vigilem/support/size_error'

# 
# 
module Vigilem::Support
  class MaxSizeError < SizeError
  
    # 
    # @param [Array || Hash] obj_and_max_size
    # @option :obj
    # @option :max_size
    def initialize(obj_and_max_size)
      obj_and_max_size = Hash[obj_and_max_size.zip([:obj, :max_size]).map(&:reverse)] if obj_and_max_size.is_a? Array
      super("size cannot exceed #{obj_and_max_size[:max_size]} for #{obj_and_max_size[:obj]}")
    end
  end
end