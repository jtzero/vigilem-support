require 'vigilem/support/core_ext'

module Vigilem
module Support
  # 
  # ObjectSpace like methods
  module ObjSpace
    
    # 
    # @return [Array]
    def all
      @all ||= []
    end
    
    # 
    # @param  component
    # @return [Array]
    def obj_register(component)
      self.all << component
      if defined?(superclass) and superclass.respond_to? :obj_register
        superclass.obj_register(component)
      end
      component
    end
  end
  
end
end
