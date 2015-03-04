require 'delegate'

module Vigilem
module Support
  #
  # a Delegator that allows it's delegate to be named later (after init)
  class LazySimpleDelegator < Delegator
    
    methods_to_include = [:to_s, :inspect, :==, :===, :<=>, :eql?, :object_id]
    
    (kd = ::Kernel.dup).class_eval do                 
      ((private_instance_methods | instance_methods) - methods_to_include).each do |m|
        remove_method m
      end
    end
    
    include kd
    
    attr_writer :strict_eql
    
    # @param obj, the delegate
    def initialize(obj=nil)
      super(obj) if obj
    end
    
    # 
    # @return [self] 
    def use_strict_eql
      @strict_eql = true
      self
    end
    
    # 
    # @return [TrueClass || FalseClass]
    def strict_eql?
      @strict_eql ||= false
    end
    
    # 
    # @see    Delegator
    # @return obj the underlying object to delegate to
    def __getobj__
      @delegate_sd_obj
    end
    
    # more visually apeeling..............#sorry
    alias_method :peel, :__getobj__
    
    # change the object delegate to obj
    # @see   Delegator
    # @param obj the object to delegate to
    def __setobj__(obj)
      raise ArgumentError, "cannot delegate to self" if self.equal?(obj)
      @delegate_sd_obj = obj
    end
    
    # compares #object_id's if #strict_eql?
    # compares the other object against @delegate_sd_obj, what are the side effects?
    # @return [TrueClass || FalseClass]
    def eql?(other)
      # @note Facets::Kerenl::respond munges the object_id
      if other.respond_to?(:__getobj__)
        if strict_eql?
          self.__getobj__.object_id.eql? other.__getobj__.object_id
        else
          self.__getobj__.eql? other.__getobj__
        end
      else
        if strict_eql?
          self.__getobj__.object_id.eql? other.object_id
        else
          self.__getobj__.eql? other
        end
      end
      
    end #eql?
    
  end
  
end
end