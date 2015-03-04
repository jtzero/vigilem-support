require 'forwardable'

module Vigilem
module Support
  # A transmutable Hash, Splits arrays into multiple keys with the same value
  # 
  # 
  #     {"a"=>:key1, "b"=>:key1, "c"=>:key1, "d"=>:key, "e"=>:key2, "f"=>:key2}
  # becomes
  # 
  #     {:key1=>["a", "b", "c"], :key2=>["e", "f"], :key => "d"}
  # 
  # And
  # 
  #     {:key1=>["a", "b", "c"], :key2=>["d", "e", "f"]}
  # becomes
  # 
  #     {"a"=>:key1, "b"=>:key1, "c"=>:key1, "d"=>:key, "e"=>:key2, "f"=>:key2}
  # And
  # 
  #     {:key1=> ['a' , ['b', 'c']]}
  # becomes
  # 
  #     {"a"=>:key1, ["b", 'c']=>:key1 }
  # 
  class TransmutableHash < Hash
    
    extend Forwardable
    
    # @param  [Hash] hsh_or_default_value
    # @param  default_value
    # @param  [Proc] default_proc
    def initialize(hsh_or_default_value={}, default_value=nil, &default_proc)
      hsh, dfault = if hsh_or_default_value.is_a?(Hash)
                      [hsh_or_default_value, default_value]
                    else
                      [{}, hsh_or_default_value]
                    end
      super(*dfault, &default_proc).merge!(hsh)
      self.invert_default = self.default
      self.invert_default_proc = self.default_proc if default_proc
    end
    
    # 
    # it will have a different object_id, because technically its a different hash
    # not sure if that's a bug
    # @return [Hash]
    def invert
      # did self change?
      if _hash_cache_ != (temp_cache = hash)
        _hash_cache_ = temp_cache
        _invert_cache_ = self.class.transmute(self)
      end
      # if it didn't change pass off the _invert_cache_
      _invert_cache_
    end
    
    # 
    # 
    def inverted?
      @inverted ||= false
    end
    
    # in-place version of #invert
    # 
    # @see    TransmutableHash#invert
    # @return [Hash]
    def invert!
      @inverted = !@inverted
      self.class[replace(invert)]
    end
    
    class << self
      # 
      # 
      # @param  [Hash] in_hash
      # @param  [Hash] dest_hash
      # @return [Hash] dest_hash
      def transmute(in_hash, dest_hash={})
        in_hash.each do |old_key, old_value|
          if old_value.is_a? Array
            old_value.uniq.each {|new_key| fuse_value(dest_hash, new_key, old_key) }
          else
            fuse_value(dest_hash, old_value, old_key) 
          end
        end
        self[dest_hash]
      end
      
      # creating somthing like ['keycode1', 'altgr', 'keycode1']
      # @param  [Hash] hsh
      # @param  key
      # @param  value
      # @return value
      def fuse_value(hsh, key, value)
        if hsh.has_key?(key)
          if (current_val = hsh[key]).is_a? Array
            current_val.concat([value])
          else
            hsh[key] = [current_val, value]
          end
        elsif value.is_a? Array
          hsh[key] = [value]
        else
          hsh[key] = value
        end
        self[hsh]
      end
      
    end
    
    # 
    # @param  [Array<Hash>]
    # @return 
    def fuse!(*hashes)
      hashes.each do |hsh|
        hsh.each do |k, v|
          self.class.fuse_value(self, k, v)
        end
      end
      self
    end
    
    # 
    # @param  [Array<Hash>]
    # @return 
    def fuse(*hashes)
      container = self.class.new
      hashes.each do |hsh|
        hsh.each do |k, v|
          self.fuse_value(hsh, k, v)
        end
      end
      container.defaults = self.defaults
      container.default_procs = self.default_procs
      container.fuze!(*hashes)
    end
    
    # fetches from the Hash all the values that have keys that match
    # the Regexp kind of like grep
    # @param  [Regexp] regex 
    # @param  [Integer] limit 
    # @return [Array] 
    def regex_fetch(regex, limit=nil)
      limit ||= -1
      key_list = self.keys.map {|key| [*key].grep(regex) }[0..limit].compact
      key_list.map {|key| self[key] }
    end
    
    def_delegator :_invert_cache_, :default=, :invert_default=
    def_delegator :_invert_cache_, :default, :invert_default
    def_delegator :_invert_cache_, :default_proc=, :invert_default_proc=
    def_delegator :_invert_cache_, :default_proc, :invert_default_proc
    
    alias_method :uninvert_default=, :default=
    alias_method :uninvert_default, :default
    alias_method :uninvert_default_proc=, :default_proc=
    alias_method :uninvert_default_proc, :default_proc
    
    # sets the default for both self and the inverted_cache
    # @see Hash#default=
    # @param  objs
    # @return objs
    def defaults=(objs)
      send(:default=, [*objs].first)
      _invert_cache_.default = [*objs].last
      objs
    end
    
    # gets the default for both self and the inverted_cache
    # @return [Array]
    def defaults
      [default(), invert_default]
    end
    
    # gets the default for both self and the inverted_cache
    # @return [Array]
    def default_procs
      [default_proc(), invert_default_proc]
    end
    
    # sets the default for both self and the inverted_cache
    # @param  objs
    # @return objs
    def default_procs=(objs)
      if fdprc = [*objs].first
        send(:default_proc=, fdprc)
      end
      if ldprc = [*objs].last
        _invert_cache_.default_proc = ldprc
      end
      objs
    end
   
   private
    attr_accessor :_hash_cache_
    attr_writer :_invert_cache_
     
    # gets the cached version of the inverse
    # @return [TransmutableHash]
    def _invert_cache_
      @_invert_cache_ ||= invert().tap {|obj| obj.instance_variable_set(:@inverted, true) }
    end
  end
end
end
