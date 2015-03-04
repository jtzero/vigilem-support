require 'vigilem/support/version'

require 'active_support/concern'

require 'vigilem/support/utils'

require 'vigilem/support/core_ext'
require 'vigilem/support/system'

require 'vigilem/ffi'

require 'vigilem/support/metadata'

module Vigilem
# 
module Support
  
  # autoload is deprecated
  # @param  [Symbol]
  # @return 
  def self.const_missing(const)
    if [:System, :TransmutableHash, :LazySimpleDelegator, :MaxSizeError, :SizeError, :Sys, :KeyMap].include? const
      require "vigilem/support/#{const.to_s.snakecase}"
      const_get(const)
    else
      super(const)
    end
  end
  
end
end
