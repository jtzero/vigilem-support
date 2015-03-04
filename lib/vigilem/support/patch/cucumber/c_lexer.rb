require 'rbconfig'

module Gherkin
  module CLexer
    def self.singleton_method_added(method_name)
      if method_name == :[] and not @overriden
        @overriden = true
        define_singleton_method(:[]) do |i18n_underscored_iso_code|
          begin
            prefix = if RbConfig::CONFIG['arch'] =~ /mswin|mingw/ && RbConfig::CONFIG['target_vendor'] != 'w64'
              "#{RbConfig::CONFIG['MAJOR']}.#{RbConfig::CONFIG['MINOR']}/"
            else
              ''
            end
            
            lib = "#{prefix}gherkin_lexer_#{i18n_underscored_iso_code}"
            require lib
            const_get(i18n_underscored_iso_code.capitalize)
          rescue LoadError => e
            e.message << %{\nCouldn't load #{lib}\nThe $LOAD_PATH was:\n#{$LOAD_PATH.join("\n")}}
            raise e
          end
        end
      else
        super(method_name)
      end
    end
    
  end
end
