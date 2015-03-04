require 'ffi'
require 'vigilem/ffi/utils'

describe ::Vigilem::FFI::Utils do
  before :all do
    FFI.typedef(:long, :number)
  end
  
  class Pts < ::FFI::Struct
    layout :x, :long,
           :y, :long
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
