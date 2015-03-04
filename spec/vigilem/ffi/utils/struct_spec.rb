require 'spec_helper'

require 'vigilem/ffi'

describe Vigilem::FFI::Utils::Struct do
  
  describe described_class::ClassMethods do
    
    describe '::members_to_methods' do
      let(:struct) do
        class Pnt < ::FFI::Struct
          include FFIUtils::Struct
          layout_with_methods :x, :long,
                              :y, :long
          self
        end
      end
      
      it 'converts the struct members to methods' do
        struct.members_to_methods
        expect(struct.instance_methods).to include(:x, :y)
      end
    end
    
    describe '::layout_with_methods' do
      let(:struct) do
        class Point < ::FFI::Struct
          include FFIUtils::Struct
          layout_with_methods :x, :long,
                              :y, :long
          self
        end
      end
      
      it 'configures the normal layout and adds them as methods' do
        expect(struct.new).to respond_to(:x, :y, :x=, :y=)
      end
    end
    
    describe '::union' do
      let(:struct) do
        class Poyhnt < ::FFI::Struct
          include FFIUtils::Struct
          layout_with_methods :x, :long,
                              :y, :long,
                  *(union(:Event) do
                    [:b, :long,
                    :z, :long]
                  end)
          self
        end
      end
      
      it 'creates a union in the class like the union keyword' do
        expect(struct.constants).to include(:Event)
      end
    end
  end
  
  context 'instance_methods' do
    let(:struct) do
      class Poynt < ::FFI::Struct
        include FFIUtils::Struct
        layout :x, :long,
               :y, :long
      end
      pt = Poynt.new
      pt[:y] = 32
      pt
    end
    
    describe '#to_h' do
      it 'returns a struct as a Hash' do
        expect(struct.to_h).to eql({:x=>0, :y=>32})
      end
    end
    
  end
end