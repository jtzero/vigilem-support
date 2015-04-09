require 'spec_helper'

require 'vigilem/ffi/utils'

require 'vigilem/ffi/struct'

describe ::Vigilem::FFI::Struct do
  
  before :all do
    Object.send(:remove_const, :Pt) if Object.const_defined?(:Pt)
    class Pt < described_class
      layout :x, :long,
             :y, :long
    end
  end
  
  after :all do
    Object.send(:remove_const, :Pt) if Object.const_defined?(:Pt)
  end
  
  describe '::[]' do
    
    let(:struct) { Pt[:y => 32] }
    
    it 'will give attrs an initial value' do
      expect(struct[:y]).to eql(32)
    end
  end
  
  describe '#inspect' do
    it 'shows the members and thier values in addition to the traditional inspect'
  end
  
  describe '#clear?' do
    let(:struct) { Pt.new }
    
    it 'returns true when struct is all "\x00"' do
      expect(struct.clear?).to be_truthy
    end
    
    it 'returns false when struct is not all "\x00"' do
      struct[:y] = 12
      expect(struct.clear?).to be_falsey
    end
    
    context 'offset > 0' do
      
      let(:pointer) { ::FFI::MemoryPointer.new(Pt, 3) }
      
      let(:struct0) do
        Pt.new(pointer)
      end
      
      let(:struct1) do
        struct0
        Pt.new(pointer.slice(ps = Pt.size, ps))
      end
      
      it 'returns true when struct is all "\x00" and pointer is not' do
        struct0[:y] = 10
        expect(struct1.clear?).to be_truthy
      end
      
      it 'returns false when struct is not all "\x00" and pointer is' do
        struct1[:y] = 12
        expect(struct1.clear?).to be_falsey
      end
    end
    
  end
end