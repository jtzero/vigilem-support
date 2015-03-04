require 'ffi'

module Vigilem
module FFI
end
end

require 'vigilem/support'

require 'vigilem/ffi/utils'
FFIUtils = ::Vigilem::FFI::Utils

require 'vigilem/ffi/utils/struct'
FFIStructUtils = FFIUtils::Struct

require 'vigilem/ffi/struct'
VFFIStruct = ::Vigilem::FFI::Struct

require 'vigilem/ffi/array_pointer_sync'
