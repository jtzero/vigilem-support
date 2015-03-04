module Vigilem
module Support
  # 
  # System detection utilities
  module System
    
    SYSTEM_NAME_MASKS = { :mac => /darwin/, :windows => (win = Gem::WIN_PATTERNS.join('|')), 
                          :win => win, :linux => /linux/, :bsd => /bsd/,
                          :nix => /nix|solaris|darwin|bsd|aix|hpux/, :aix => /aix/ }
                          #:java => /java/}
    
    # 
    # @todo FFI::Platform || Fiddle::WINDOWS
    # generates os_name? methods
    # @return [Regexp]
    SYSTEM_NAME_MASKS.each do |mask_name, mask|
      define_method(:"#{mask_name}?") do
        os =~ SYSTEM_NAME_MASKS[mask_name]
      end
    end
    
    # 
    # @return [String] 
    def os
      RbConfig::CONFIG['host_os']
    end
    
    # this will may mis-represent check out https://bugs.ruby-lang.org/issues/8568
    # the size of a long
    # @return [Integer]
    def long_length
      @long_len ||= [0].pack('L!').bytesize
    end
    
    # 
    # @return [TrueClass || FalseClass]
    def x64bit?
      @x64_bit ||= [nil].pack('p').bytesize == 8
    end
    
    # 
    # @return [TrueClass || FalseClass]
    def x32bit?
      not self.x64bit?
    end
    
    # 
    # @return [TrueClass || FalseClass]
    def big_endian?
      [1].pack('I') == [1].pack('N')
    end
    
    # 
    # @return [TrueClass || FalseClass]
    def little_endian?
      !big_endian?
    end
    
    # 
    # @param  [Numeric] number
    # @return the same number converted to a native signed long
    def native_signed_long(number)
      [number].pack('l!').unpack('l!').first
    end
    
    PACKVAR = 'ABCDEFGHILMNPQSUVWXZ'
    
    # replace/supplement with Fiddle::Importer#sizeof, ruby2c, MakeMakefile#check_sizeof
    # @see    String#unpack
    # @see    Array#pack
    # @param  [String] format
    # @return [Integer] the fize of the format
    def sizeof(format)
      # Only for numeric formats, String formats will raise a TypeError
      elements = 0
      format.scan(/[#{PACKVAR}]_?\d*/i) do |mtch|
        if mtch =~ /\d+/
          elements += mtch.gsub('_', '')[1..-1].to_i
        elsif mtch !~ /!|_/
          elements += 1
        end
      end
      ([ 0 ] * elements).pack(format).length # bytesize?
    end
    
    extend self
      
  end
end
end

require 'vigilem/support/sys'
