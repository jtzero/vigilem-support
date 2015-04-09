require 'spec_helper'

require 'vigilem/ffi'

describe ::Vigilem::FFI::Utils do
  
  before :all do
    # @todo shouldn't be needed each files should clean up after itself
    Object.send(:remove_const, :Pt) if Object.const_defined?(:Pt)
    Object.send(:remove_const, :Pts) if Object.const_defined?(:Pts)
    Object.send(:remove_const, :Tri) if Object.const_defined?(:Tri)
    FFI.typedef(:long, :number)
    class Pts < ::FFI::Struct
      layout :x, :long,
             :y, :long
    end
  end
  
  after :all do
    Object.send(:remove_const, :Pts) if Object.const_defined?(:Pts)
  end
  
  context 'struct' do
    
    let(:struct) do
      pt = Pts.new
      pt[:y] = 32
      pt
    end
    
    describe '::struct_to_h' do
      it 'return struct as a Hash' do
        expect(described_class.struct_to_h(struct)).to eql({:x=>0, :y=>32})
      end
    end
    
    describe '::_struct_to_h' do
      it 'return struct as a Hash' do
        expect(described_class._struct_to_h(struct)).to eql({:x=>0, :y=>32})
      end
    end
    
  end
  
  describe '::get_builtin_type_name' do
    before(:each) do
      FFI.typedef(:string, :text)
    end
    
    it 'can only resolve to builtin types' do
      expect { FFIUtils.get_builtin_type_name(:str) }.to raise_error(TypeError)
    end
    
    it 'will pick up custom types' do
      expect(FFIUtils.get_builtin_type_name(:text)).to eql(:string)
    end
  end  
  
  describe '#ptr_capacity' do
    let(:pointer) { FFI::MemoryPointer.new(:uint, 3) }
    
    it 'returns the #size/#type_size' do
      expect(described_class.ptr_capacity(pointer)).to eql(3)
    end
  end
  
  describe '::clear?' do
    let(:pointer) { FFI::MemoryPointer.new(:uint, 3) }
    
    it 'returns the true when the pointer is all "\x00"' do
      expect(described_class.clear?(pointer)).to be_truthy
    end
    
    it 'returns the true when the pointer is "\x00" past the offset' do
      pointer.put_uint(0, 7)
      expect(described_class.clear?(pointer, FFI.find_type(:uint).size * 2)).to be_truthy
    end
  end
  
  describe '::write_typedef' do
    before(:each) do
      @ptr = FFI::MemoryPointer.new(:number, 1)
    end
    
    it 'will write 12 to the pointer' do
      FFIUtils.write_typedef(@ptr, :number, 12)
      expect(@ptr.read_long).to eql(12)
    end
  end
  
  describe '::write_array_typedef' do
    before(:each) do
      @ptr = FFI::MemoryPointer.new(:number, 3)
    end
    
    it 'writes array [12, 13, 14] to the pointer' do
      FFIUtils.write_array_typedef(@ptr, :number, [12, 13, 14])
      expect(@ptr.read_array_of_long(3)).to eql([12, 13, 14])
    end
    
    it 'writes array [12] to the pointer and not segfault' do
      FFIUtils.write_array_typedef(@ptr, :number, 12)
      expect(@ptr.read_array_of_long(3)).to eql([12, 0, 0])
    end
  end
  
  describe '::read_typedef' do
    before(:each) do
      @ptr = FFI::MemoryPointer.new(:number, 1)
    end
    
    it 'reads 12 from the pointer' do
      @ptr.write_long(12)
      expect(FFIUtils.read_typedef(@ptr, :number)).to eql(12)
    end
  end
  
  describe '::read_array_typedef' do
    before(:each) do
      @ptr = FFI::MemoryPointer.new(:number, 3)
    end
    
    it 'reads array [12, 13, 14] from the pointer' do
      @ptr.write_array_of_long([12, 13, 14])
      expect(FFIUtils.read_array_typedef(@ptr, :number, 3)).to eql([12, 13, 14])
    end
  end
  
  describe '::put_array_typedef' do
    before(:each) do
      @ptr = FFI::MemoryPointer.new(:number, 3)
    end
    
    it 'puts array [12] into the pointer at offset @ptr.type_size and not segfault' do 
      FFIUtils.put_array_typedef(@ptr, :number, 12, @ptr.type_size)
      expect(@ptr.read_array_of_long(3)).to eql([0, 12, 0])
    end
    
    it 'puts array [12] into the pointer at offset @ptr.type_size' do
      FFIUtils.put_array_typedef(@ptr, :number, [12], @ptr.type_size)
      expect(@ptr.read_array_of_long(3)).to eql([0, 12, 0])
    end
    
    it 'puts array [12] into the pointer at offset 1' do
      FFIUtils.put_array_typedef(@ptr, :number, [12], 1)
      expect(@ptr.read_array_of_long(3)).to eql([3072, 0, 0])
    end
  end
  
  describe '::put_typedef' do
    before(:each) do
      @ptr = FFI::MemoryPointer.new(:number, 3)
    end
    
    it 'puts array [12] in the pointer at offest 0' do
      FFIUtils.put_typedef(@ptr, :number, 12)
      expect(@ptr.read_array_of_long(3)).to eql([12, 0, 0])
    end
    
    it 'puts array [12] in the pointer at offset 1' do
      FFIUtils.put_typedef(@ptr, :number, 12, 1)
      expect(@ptr.read_array_of_long(3)).to eql([3072, 0, 0])
    end
  end
  
  describe '::replace_typedef' do
    before(:each) do
      @ptr = FFI::MemoryPointer.new(:number, 1)
      @ptr.write_long(5)
    end
    
    it 'replaces the 5 in the before ptr with 13' do
      FFIUtils.replace_typedef(@ptr, :number, 13)
      expect(@ptr.read_long).to eql(13)
    end
  end
  
  describe '::add_int_typedef' do
    before(:each) do
      @ptr = ::FFI::MemoryPointer.new(:number, 1)
      @ptr.write_long(5)
    end
    
    it 'concats 3 to the 5 in the before ptr' do
      FFIUtils.add_int_typedef(@ptr, :number, 3)
      expect(@ptr.read_long).to eql(8)
    end
  end
  
  describe '::fields' do
    before :all do
      class Pt < FFI::Struct
        layout :x, :long,
               :y, :long
      end
    end
    
    let(:return_value) { Pt.layout.fields }
    
    context 'object param' do
      it 'returns an a array of FFI::StructLayout::Field' do
        expect(described_class.fields(Pt.new)).to eql(return_value)
      end
    end
    
    context 'class param' do
      it 'returns an a array of FFI::StructLayout::Field' do
        expect(described_class.fields(Pt)).to eql(return_value)
      end
    end
    
    after :all do
      Object.send(:remove_const, :Pt) if Object.const_defined?(:Pt)
    end
  end
  
  context 'bulk_assigning' do 
    before :all do
      class Pt < FFI::Struct
        layout :x, :long,
               :y, :long
      end
      
      class Tri < FFI::Struct
        layout :a, Pt,
                :b, Pt,
                :c, Pt
      end
      
    end
    
    after :all do
      Object.send(:remove_const, :Pt) if Object.const_defined?(:Pt)
      Object.send(:remove_const, :Tri) if Object.const_defined?(:Tri)
    end
    describe '::_struct_bulk_assign' do
      
      it 'takes an Array of values and assigns it to the struct object' do
        described_class._struct_bulk_assign(Tri.new, Tri.layout.fields.first, :a, [[1,2]])
      end
      
      it 'raises an ArgumentError when trying to assign an non enumerable to a struct' do
        expect do
          described_class._struct_bulk_assign(Tri.new, Tri.layout.fields.first, :a, [1,2])
        end.to raise_error(ArgumentError)
      end
    end
    
    describe '::struct_bulk_assign' do
      
      it 'builds the struct from the Array values given in' do
        tri = Tri.new
        described_class.struct_bulk_assign(tri, [[0,9], [16,0], [16, 9]])
        expect([[0,9], [16,0], [16, 9]]).to eql([tri[:a].values, tri[:b].values, tri[:c].values])
      end
      
      it 'builds the struct from the Hash values given in' do
        tri = Tri.new
        described_class.struct_bulk_assign(tri, {:b => [16,0], :a => [0,9], :c => [16, 9]})
        expect([[0,9], [16,0], [16, 9]]).to eql([tri[:a].values, tri[:b].values, tri[:c].values])
      end
      
      context 'Union assignment' do
        
        before :all do
          class FTextItemSU < FFI::Union
            layout :sdata, :string,
                    :idata, :int
          end
          class FTextItemU < FFI::Union
            layout :idata, :int,
                    :fdata, :float
          end
        end
        
        let(:ftext_itemu) { FTextItemU.new }
        
        after :all do
          Object.send(:remove_const, :FTextItemSU) if Object.const_defined?(:FTextItemSU)
          Object.send(:remove_const, :FTextItemU) if Object.const_defined?(:FTextItemU)
        end
        
        it 'cannot build an item with a string datatype, because as of FFI 1.9.8 it cannot store or reference strings with ::[]' do
          expect do 
            described_class.struct_bulk_assign(FTextItemSU.new, ['asdf'])
          end.to raise_error(ArgumentError)
        end
        
        it 'raises error when trying to assign Array to a Union' do
          expect do 
            described_class.struct_bulk_assign(ftext_itemu, [13])
          end.to raise_error(ArgumentError)
        end
        
        let(:fdata) { 5.2 }
        
        let(:unpack_ary) { [[/16/, 's'], [/32/, 'l'], [/64/, 'q'] ] }
        
        let(:float_interpreted_as_int) do
          type = described_class.get_builtin_type_name(FTextItemU.layout.fields.first.type)
          str = unpack_ary.find {|r, s| r =~ type }.last
          if(big_endian = [1].pack('I') == [1].pack('N'))
            [fdata].pack('g').unpack(str).first
          else
            [fdata].pack('f').unpack(str).first
          end
        end
        
        it 'builds the struct from the Hash values given in' do
          described_class.struct_bulk_assign(ftext_itemu, {:fdata => fdata})
          
          expect(ftext_itemu[:idata]).to eql(float_interpreted_as_int)
        end
        
      end
      
    end
    
  end
  
  describe '#bytes_to_structs' do
    it 'converts a string of bytes to an arrys of structs' do
      str_bytes = [12, 13, 14, 15, 16, 17].pack('L!6')
      
      expect(described_class.bytes_to_structs(Pts, str_bytes).map {|pts| [pts, pts.values] }).to match [
        [instance_of(Pts), [12, 13]],
        [instance_of(Pts), [14, 15]],
        [instance_of(Pts), [16, 17]]
      ]
    end
  end
  
  describe '::ary_of_type' do
    
    let(:pointer) do 
      poynter = FFI::MemoryPointer.new(:uint, 3)
      Vigilem::FFI::Utils.put_array_typedef(poynter, :uint, [1, 2, 3])
      poynter
    end
    
    it 'converts a FFI::Pointer to an array of :uint' do
      expect(described_class.ary_of_type(:uint, FFI.find_type(:uint).size, pointer)).to eql([1, 2, 3])
    end
    
    context 'partially empty pointer' do
      let(:part_pointer) do 
        poynter = FFI::MemoryPointer.new(:uint, 6)
        Vigilem::FFI::Utils.put_array_typedef(poynter, :uint, [1, 2, 3])
        poynter
      end
      
      it %q<converts a FFI::Pointer to a array of :uint, including the nulls, "\x00" is indistinguishable from `0'> do
        expect(described_class.ary_of_type(:uint, FFI.find_type(:uint).size, part_pointer)).to eql([1, 2, 3, 0, 0, 0])
      end
    end
    
    context 'given a FFI::Struct' do
      
      class FFIPoints < FFI::Struct
        layout :x, :uint, :y, :uint
      end
      
      let(:points_array) do
        3.times.map do 
          arg = Points.new
          arg[:x] = 1
          arg[:y] = 2
          arg
        end
      end
      
      let(:points_bytes_array) do
        points_array.map {|pa| (ptr = pa.to_ptr).read_bytes(ptr.size) }
      end
      
      let(:points_pointer) do
        poynter = FFI::MemoryPointer.new(Points, 3)
        poynter.write_bytes(points_bytes_array.join)
        poynter
      end
      
      it 'converts a pointer to an array FFI::Struct' do
        result = described_class.ary_of_type(FFIPoints, FFIPoints.size, points_pointer).map.with_index do |ffi_pnt, idx|
          ffi_pnt.to_ptr.read_bytes(FFIPoints.size)
        end
        
        expect(result).to eql(points_bytes_array)
      end
    end
    
    context 'given a VFFIStruct' do
      class Points < VFFIStruct
        layout :x, :uint, :y, :uint
      end
      
      let(:points_array) do
        3.times.map do 
          arg = Points.new
          arg[:x] = 1
          arg[:y] = 2
          arg
        end
      end
      
      let(:points_pointer) do
        poynter = FFI::MemoryPointer.new(Points, 3)
        poynter.write_bytes(points_array.map(&:bytes).join)
        poynter
      end
      
      it 'converts a pointer to an array of VFFI' do
        expect(described_class.ary_of_type(Points, Points.size, points_pointer).map(&:bytes)).to eql(points_array.map(&:bytes))
      end
      
    end
    
  end
  
end
