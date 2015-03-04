require 'spec_helper'

require 'vigilem/ffi/utils'

require 'vigilem/ffi/struct'

describe ::Vigilem::FFI::Struct do
  describe '::[]' do
    let(:struct) do
      class Pt < described_class
        layout :x, :long,
               :y, :long
      end
      pt = Pt[:y => 32]
      pt
    end
    
    it 'will give attrs an initial value' do
      expect(struct[:y]).to eql(32)
    end
  end
end