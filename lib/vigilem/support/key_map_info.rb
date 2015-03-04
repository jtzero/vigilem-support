module Vigilem
module Support
  # 
  # 
  class KeyMapInfo
    
    # 
    # @param [Hash] opts
    def initialize(attrs={})
      attrs.each {|attr| send(:"#{attr}=", opts[attr]) }
    end
    
    # 
    # @return [Array<Symbol>]
    def self.attrs
      @attrs ||= [:keycode_range, :max_actions, 
                  :number_of_functions_keys, :keymaps_in_use,
                  :max_compose_defs, :compose_defs, 
                  :compose_defs_in_use, :mod_weights, :keysyms]
    end
    
    attr_accessor *attrs
    
    # 
    # @param  [String] str
    # @return [KeyMapInfo] 
    def self.load_string(str)
      (kmi = new).load_string(str)
      kmi
    end
    
    # 
    # @param  [String] str
    # @return 
    def load_string(str)
      str.lines do |substr|
        case substr
        when /^keycode range supported by kernel:/
          keycode_range = substr.split(/:\s+/).last.rstrip
        when /^max number of actions bindable to a key:/
          max_actions = substr.split(/:\s+/).last.rstrip
        when /^number of keymaps in actual use:/
          keymaps_in_use = substr.split(/:\s+/).last.rstrip
        when /^number of function keys supported by kernel:/
          number_of_function_keys = substr.split(/:\s+/).last.rstrip
        when /^max nr of compose definitions:/
          max_compose_defs = substr.split(/:\s+/).last.rstrip
        when /^nr of compose definitions in actual use:/
          compose_defs_in_use = substr.split(/:\s+/).last.rstrip
        when /^0x0[\dA-z]+/
          hex_str, sym = substr.split(/\s+/)
          keysyms[hex_str] = sym.rstrip
        when /[a-z_]\s+for/i
          # synonyms
        when /^(shift|alt|control|ctrl|capsshift)(l|r|gr)?/
          mod, col = substr.split(/\s+/)
          mod_weights[mod] = col.rstrip.to_i
        end
      end
    end
    
    # 
    # @return [Hash]
    def keysyms
      @keysyms ||= {}
    end
    
    
    # 
    # @return [Hash]
    def char_refs
      keysyms.invert
    end
    
    # 
    # @return [Hash]
    def mod_weights
      @mod_weights ||= {}
    end
    
    alias_method :mod_columns, :mod_weights
    
  end
end
end
