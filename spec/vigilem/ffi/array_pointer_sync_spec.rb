require 'spec_helper'

require 'vigilem/ffi'

describe Vigilem::FFI::ArrayPointerSync do
  
  def ary_type
    :uint
  end
  
  before :all do
    InitLessHost = Class.new do
      def self.ary_type
        :uint
      end
      include Vigilem::FFI::ArrayPointerSync
    end
  end
  
  let(:init_less_host) { InitLessHost.new }
  
  context '::included' do
    it 'will set the native_type to POINTER' do
      expect(InitLessHost.native_type).to eql(FFI::Type::POINTER)
    end
  end
  
  context 'without initialize_ary_ptr_sync' do
    context 'point_cuts' do
      it 'will have only array manipulation methods' do
        expect(described_class.instance_variable_get(:@point_cuts)).to_not include([
                             *Array.instance_methods.grep(/method|taint|trust|instance_variable|send|class|respond/),
                                                               :__id__, :object_id, :extend, :freeze, :is_a?, :instance_of? ])
      end
    end
    
    context described_class::ClassMethods do
      
      it 'will include FFI::DataConverter' do
        init_less_host.initialize_ary_ptr_sync(5)
        expect(init_less_host.class).to be_a(FFI::DataConverter)
      end
      
      describe '::ary_type' do
        let(:fail_host) do
          FailInitLessHost = Class.new do
            include Vigilem::FFI::ArrayPointerSync
            self
          end
        end
        
        it 'raises NotImplementedError when not overriden' do
          expect do
            fail_host.ary_type
          end.to raise_error(NotImplementedError)
        end
      end
      
      describe '::ary_type_size' do
        context 'is a Symbol' do
          it 'returns the size of ary_type' do
            expect(init_less_host.class.ary_type_size).to eql(::FFI.find_type(init_less_host.class.ary_type).size)
          end
        end
        
        context 'is a Class' do
          
          before do
            Coord = Class.new(::FFI::Struct) do
              layout :x, :short,
                     :y, :short
              self
            end
            ClassArrayTypeInitLessHost = Class.new do
              def self.ary_type
                Coord
              end
            end #Class.new
          end
          
          it 'returns the size of ary_type' do
            expect(init_less_host.class.ary_type_size).to eql(Coord.size)
          end
        end
      end
      
      describe '::ptr_capacity' do
        
        let(:pointer) { FFI::MemoryPointer.new(:uint, 3) }
        
        it 'gets the capacity of the pointer based on ::ary_type_size' do
          expect(InitLessHost.ptr_capacity(pointer)).to eql(3)
        end
      end
      
      describe '::ary_of_type' do
        
        let(:pointer) do 
          poynter = FFI::MemoryPointer.new(:uint, 3)
          Vigilem::FFI::Utils.put_array_typedef(poynter, :uint, [1, 2, 3])
          poynter
        end
        
        it 'converts a FFI::Pointer to an array_sync of ary_type' do
          expect(InitLessHost.ary_of_type(pointer)).to eql([1, 2, 3])
        end
        
        context 'given a FFI::Struct' do
          
          class FFIPoints < FFI::Struct
            layout :x, :uint, :y, :uint
          end
          
          let(:points_array) do
            3.times.map do 
              arg = FFIPoints.new
              arg[:x] = 1
              arg[:y] = 2
              arg
            end
          end
          
          let(:points_bytes_array) do
            points_array.map {|pa| (ptr = pa.to_ptr).read_bytes(ptr.size) }
          end
          
          let(:points_pointer) do
            poynter = FFI::MemoryPointer.new(FFIPoints, 3)
            poynter.write_bytes(points_bytes_array.join)
            poynter
          end
          
          class FFIHost
            def self.ary_type
              FFIPoints
            end
            include Vigilem::FFI::ArrayPointerSync
          end
          
          it 'converts a FFI::Struct to an array_sync of ary_type' do
            result = FFIHost.ary_of_type(points_pointer).map.with_index do |ffi_pnt, idx|
              ffi_pnt.to_ptr.read_bytes(FFIHost.ary_type_size)
            end
            
            expect(result).to eql(points_bytes_array)
          end
        end
        
        context 'given a VFFIStruct' do
          class VFFIPoints < VFFIStruct
            layout :x, :uint, :y, :uint
          end
          
          let(:points_array) do
            3.times.map do 
              arg = VFFIPoints.new
              arg[:x] = 1
              arg[:y] = 2
              arg
            end
          end
          
          let(:points_pointer) do
            poynter = FFI::MemoryPointer.new(VFFIPoints, 3)
            poynter.write_bytes(points_array.map(&:bytes).join)
            poynter
          end
          
          let(:vffi_host) do
            VFFIHost = Class.new do
              def self.ary_type
                VFFIPoints
              end
              include Vigilem::FFI::ArrayPointerSync
            end
          end
          
          it 'converts it to an array_sync of ary_type' do
            expect(vffi_host.ary_of_type(points_pointer).map(&:bytes)).to eql(points_array.map(&:bytes))
          end
          
        end
        
      end
      
      describe '::raise_size_error' do
        it 'raises NameError "size cannot exceed #{obj.max_size} for #{obj}" ' do
          expect do
            Host.raise_size_error
          end.to raise_error(NameError)
        end
      end
      
    end
    
  end
  
  describe '#initialize_ary_ptr_sync' do
    
    context 'not called' do
      it 'will not have initialized the ptr_cache_hash' do
        expect(init_less_host.send(:ptr_cache_hash)).to be_nil
      end
      
      it 'will not have initialized the cache_hash' do
        expect(init_less_host.send(:cache_hash)).to be_nil
      end
      
      it 'will not have initialized the ptr' do
        expect do 
          init_less_host.ptr
        end.to raise_error(TypeError)
      end
    end
    context 'called' do
      
      before(:each) do
        init_less_host.initialize_ary_ptr_sync(5)
      end
      
      let(:init_size) { 5 }
      
      let(:init_ptr) { FFI::MemoryPointer.new(ary_type, init_size) }
      
      let(:init_ary) { [1, 2, 3] }
      
      it 'sets up the ptr cache' do
        expect(init_less_host.send(:ptr_cache_hash)).to_not be_nil
      end
      
      it 'sets up the array cache' do
        expect(init_less_host.send(:cache_hash)).to_not be_nil
      end
      
      context 'with a pointer arg' do
        
        before(:each) { init_less_host.initialize_ary_ptr_sync(init_ptr) }
        
        it 'will init the ptr' do
          expect(init_less_host.ptr).to_not be_nil
        end
        
        it 'will get the max_len from the pointer' do
          expect(init_less_host.max_size).to eql(init_size)
        end
        
      end
      
      context 'pointer arg with init_values' do
        it 'will raise error if given both a pointer and initial values' do
          expect do
            init_less_host.initialize_ary_ptr_sync(init_ptr, init_ary)
          end.to raise_error(ArgumentError)
        end
      end
      
      context 'with a max_len arg' do
        
        it 'inits max_size' do
          init_less_host.initialize_ary_ptr_sync(init_size)
          expect(init_less_host.max_size).to eql(init_size)
        end
        
        it 'throws and error when init_size does not respond to #to_i' do
          expect do
            init_less_host.initialize_ary_ptr_sync(Object.new)
          end.to raise_error(TypeError)
        end
        
      end
      context 'with max_len and init_values' do
        
        before(:each) { init_less_host.initialize_ary_ptr_sync(init_size, *init_ary) }
        
        it 'sets the max_size' do
          expect(init_less_host.max_size).to eql(init_size)
        end
        
        it 'inserts some starter values' do
          expect(init_less_host.send(:ary)).to eql(init_ary)
        end
      end
      
    end
  end
  
  context 'after init' do
  
    before :all do
      Host = Class.new do
        def self.ary_type
          :uint
        end
        include Vigilem::FFI::ArrayPointerSync
        def initialize(max_len_or_ptr, *init_values)
          initialize_ary_ptr_sync(max_len_or_ptr, *init_values)
        end
      end
    end
    
    let(:host) { Host.new(3) } 
    
    describe '#after_ary_method' do
      let(:array_intercept_host) do
        ArrayInterceptInitLessHost = Class.new do
          def self.ary_type
            :uint
          end
          include Vigilem::FFI::ArrayPointerSync
          def after_ary_method(method_name, return_value, *args, &block)
            'HAHA! not the value you wanted'
          end
        end
        ArrayInterceptInitLessHost.new.initialize_ary_ptr_sync(20)
      end
      
      it 'is executed after array methods' do
        expect(array_intercept_host << 1).to eql('HAHA! not the value you wanted')
      end
    end
    
    describe '#max_size, #max_size=' do
      let(:len) { 1 }
      
      it 'max_size will be updated' do
        host.send(:max_size=, len)
        expect(host.max_size).to eql(len)
      end
      
      it 'max_len will be the same as max_size' do
        host.send(:max_size=, len)
        expect(host.max_len).to eql(host.max_size)
      end
    end
    
    describe '#max_len, #max_len=' do
      let(:len) { 1 }
      
      it 'max_len will be updated' do
        host.send(:max_len=, len)
        expect(host.max_len).to eql(len)
      end
      
      it 'max_size will be the same as max_len' do
        host.send(:max_len=, len)
        expect(host.max_size).to eql(host.max_len)
      end
    end
    
    describe '#replace' do
      # @todo
      #let!(:host) { host.concat([1, 2]) } # so this fails silently
      
      it 'will work just like Array#replace' do
        expect(host.replace([3, 4]).to_a).to eql([3,4])
      end
    end
    describe '#bytes' do
      it 'reads all the bytes from the pointer' do
        host.concat([1, 2])
        empty = "\x00" * (host.ptr.type_size - 1)
        expect(host.bytes).to eql("\x01#{empty}\x02#{empty}\x00#{empty}")
      end
    end
    
    describe '::bytes_of' do
      it 'gets the bytes of an item in the array specified by index' do
        host.concat([1, 2])
        empty = "\x00" * (host.ptr.type_size - 1)
        expect(host.bytes_of(1)).to eql("\x02#{empty}")
      end
    end
    
    describe '#offsets' do
      
      it %q(returns the offset of the objects in the array on the pointer it's in) do
        host.concat([1, 2, 4])
        len = host.ptr.type_size
        expect(host.offsets).to eql([0, len, len *2])
      end
    end
    
    describe '#ptr' do
      context 'array_pointer_sync is empty' do
        it 'returns the underlying pointer, null' do
          ptr = host.ptr
          host_bytes = ptr.get_bytes(0, ptr.size)
          expect(host_bytes).to eql("\x00" * (host.max_size! * ::FFI.find_type(Host.ary_type).size))
        end
      end
    end
    
    context 'private' do
      
      describe '#ary' do
        it 'defaults to empty' do
          expect(host.send(:ary)).to eql([])
        end
      end
      
      describe '#_size' do
        let(:part_dble_host) do 
          allow(host).to receive(:array).and_call_original
          allow(host).to receive(:update)
          allow(host).to receive(:_size).and_call_original
          host.send(:ary).concat([1, 2, 3])
          host
        end
        
        it 'returns the size' do
          expect(part_dble_host.send(:_size)).to eql(3)
        end
        
        it %q(won't call :update) do
          expect(part_dble_host).to_not have_received(:update)
        end
      end
      
      describe '#ptr_hash' do
        it 'creates a hash for the values in the ptr' do
          expect(host.send(:ptr_hash)).to eql(host.ptr.read_bytes(host.ptr.size).hash)
        end
      end
      
      describe '#ptr_changed?' do
        
        context 'nothing changed' do
          it 'will return false when the pointer has not changed' do
            expect(host.send(:ptr_changed?)).to be_falsey
          end
        end
        
        context 'ptr value changed' do
          it %q(will return true when the pointer value changed and update hasn't ran) do
            Vigilem::FFI::Utils.write_array_typedef(host.ptr, Host.ary_type, [1,2])
            expect(host.send(:ptr_changed?)).to be_truthy
          end
        end
        
      end 
      
      describe '#update_ptr_cache' do
        it 'updates the cache of the pointer with the new pointer value' do
          old_hsh = host.send(:ptr_cache_hash)
          Vigilem::FFI::Utils.write_array_typedef(host.ptr, Host.ary_type, [1,2])
          expect(host.send(:update_ptr_cache)).not_to eql(old_hsh)
        end
      end
      
      describe '#update_ptr' do
        
        let(:input) { [1, 2, 3] }
        
        it 'updates the ptr from the #ary values' do
          host.send(:ary).concat(input)
          expect(host.bytes).to eql(input.pack('L*'))
        end
      end
      
      describe '#ary_changed?' do
        context 'nothing changed' do
          it 'will return false when the ary has not changed' do
            expect(host.send(:ary_changed?)).to be_falsey
          end
        end
        
        context 'ary value changed' do
          it %q(will return true when the ary value changed and update hasn't ran) do
            host.send(:ary) << 1
            expect(host.send(:ary_changed?)).to be_truthy
          end
        end
      end
      
      describe 'update_ary_cache' do
        it 'updates the cache of the ary with the new pointer value' do
          old_hsh = host.send(:cache_hash)
          host.send(:ary).concat([1,2,3])
          expect(host.send(:update_ary_cache)).not_to eql(old_hsh)
        end
      end
      
      describe '#update_ary' do
        
        let(:input) { [1, 2, 3] }
        
        it 'updates the #ary from the #ptr values' do
          Vigilem::FFI::Utils.write_array_typedef(host.ptr, Host.ary_type, input)
          host.send(:update_ary)
          expect(host.send(:ary)).to eql(input)
        end
      end
      
      describe '#update_cache' do
        it 'updates both caches' do
          old_caches = [host.send(:cache_hash), host.send(:ptr_cache_hash)]
          host.send(:ary).concat([1,2,3])
          Vigilem::FFI::Utils.write_array_typedef(host.ptr, Host.ary_type, [1,2])
          expect(host.send(:update_cache)).not_to eql(old_caches)
        end
      end
      
      describe '#update' do
        let(:input) { [1, 2, 3] }
        
        it 'updates the ptr if the ary was updated' do
          host.send(:ary).concat(input)
          host.send(:update)
          expect((pt = host.send(:ptr)).read_bytes(pt.size)).to eql(input.pack('L*'))
        end
        
        it 'updates the ary if the ptr was updated' do
          Vigilem::FFI::Utils.write_array_typedef(host.ptr, Host.ary_type, [1,2,3])
          host.send(:update)
          expect(host.send(:ary)).to eql(input)
        end
      end
      
      describe '#raise_size_error' do
        it 'raises size error' do
          expect do
            host.send(:_raise_size_error)
          end.to raise_error(Vigilem::Support::MaxSizeError)
        end
      end
      
      describe '#_ptr_offsets' do
        it 'returns an array of offsets based on the size of the array and type size of the elements' do
          host.send(:ary).concat([1,2,3,4])
          expect(host.send(:_ptr_offsets)).to eql([0, 4, 8, 12])
        end
      end
    end # private
    
    # @todo change some of the wording
    describe '#what_changed? and #changed?,' do
        
      context 'nothing changed,' do
        it 'then returns all false' do
          expect(host.what_changed?.values.all?).to be_falsey
        end
        
        it 'then changed? is false' do
          expect(host.changed?).to be_falsey
        end
      end
        
      context 'ary_changed?' do
        before(:each) { host.send(:ary) << 1 }
        
        it 'then array => true' do
          expect(host.what_changed?).to eql({ary: true, ptr: false})
        end
        
        it 'then changed? is true' do
          expect(host.changed?).to be_truthy
        end
      end
      context 'ptr_changed?' do
        before(:each) { Vigilem::FFI::Utils.write_array_typedef(host.ptr, Host.ary_type, [1,2]) }
        
        it 'then :ptr => true' do
          expect(host.what_changed?).to eql({ary: false, ptr: true})
        end
        
        it 'then changed? is true' do
          expect(host.changed?).to be_truthy
        end
      end
      context 'both changed' do
        it 'then raises an error' do
          host.send(:ary) << 1
          Vigilem::FFI::Utils.write_array_typedef(host.ptr, Host.ary_type, [1, 2])
          expect do 
            host.what_changed?
          end.to raise_error(RuntimeError)
        end
        
        it 'then changed? is raises error' do
          host.send(:ary) << 1
          Vigilem::FFI::Utils.write_array_typedef(host.ptr, Host.ary_type, [1, 2])
          expect do 
            host.changed?
          end.to raise_error(RuntimeError)
        end
      end
    end
    
    describe '#out_of_bounds?' do
      it 'returns false when array.size <= max_size' do
        host.send(:ary).concat([1])
        expect(host.out_of_bounds?).to be_falsey
      end
      it 'returns true when array.size > max_size' do
        host.send(:ary).concat([1, 2, 3, 4, 5])
        expect(host.out_of_bounds?).to be_truthy
      end
    end
    
    describe 'out_of_bounds_check' do
      it 'returns nil if not out of bounds' do
        host.send(:ary).concat([1])
        expect(host.out_of_bounds_check).to be_nil
      end
      it 'raises error when out of bounds' do
        host.send(:ary).concat([1, 2, 3, 4, 5])
        expect do
          host.out_of_bounds_check
        end.to raise_error(Vigilem::Support::MaxSizeError)
      end
    end
    
    describe '#to_s' do
      it 'resembles an array' do
        host << 1
        expect(host.to_s).to eql("[1]")
      end
    end
    
    describe '#to_a' do
      it 'gets the array representation of the ary_sync' do
         expect(host.to_a).to eql(host.send(:ary))
      end
    end
    
    describe '#dup' do
      before(:each) do
        host.concat([1, 2, 3])
      end
      let(:dup) { host.dup }
      it 'duplicates the values of ary_ptr_sync' do
        expect(host.send(:ary)).to eql(dup.send(:ary))
      end
      
      it 'creates a new object' do
        expect(host.object_id).not_to eql(dup.object_id)
      end
      
    end
    
    describe '#pop' do
      context 'pointer array' do
        
        before :all do
          class Pnt < ::FFI::Struct
            layout :x, :long,
                   :y, :long
            
            class << self
              def native_type
                ::FFI::Pointer
              end
              
              def to_native(value, ctx)
                value.to_ptr
              end
            end
          end
          
          class PointAry
            def self.ary_type
              Pnt
            end
            include Vigilem::FFI::ArrayPointerSync
            def initialize(max_len_or_ptr, *init_values)
              initialize_ary_ptr_sync(max_len_or_ptr, *init_values)
            end
          end
        end
        
        let(:points) do
          0.upto(5).each_slice(2).map do |n, n_1|
            obj = Pnt.new
            obj[:x] = n
            obj[:y] = n_1
            obj
          end
        end
        
        let(:point_ary) do
          PointAry.new(3)
        end
        
        before(:each) do
          point_ary.concat(points)
        end
        
        it 'removes an item from the stack' do
          expect(point_ary.pop).to be_a(Pnt) and have_attributes( x: 4, y: 5 )
        end
        
        it 'will not be Hash equal to an array' do
          point_ary.pop
          expect(point_ary).not_to eql(points[0..1])
        end
        
        it 'will modify the original array' do
          point_ary.pop
          expect(point_ary).to be_an(PointAry) and match [
            an_object_having_attributes( x: 0, y: 1 ),
            an_object_having_attributes( x: 2, y: 3 )
          ]
        end
      end
      
      context 'simple array' do
        before(:each) do
          host.concat([1, 2, 3])
        end
        
        it 'removes an item from the stack' do
          expect(host.pop).to eql(3)
        end
        
        it 'will not be Hash equal to an array' do
          host.pop
          expect(host).not_to eql([1, 2])
        end
        
        it 'will modify the original array' do
          host.pop
          expect(host).to be == [1,2]
        end
      end
    end
    
    describe '#inspect' do
      it 'produces a string with all variables' do
        expect(host.inspect).to match(
        /#<[A-Z][a-z\d]+:0x[a-z\d]+ \[.*\] @max_size=\d+ @ptr=#<FFI::MemoryPointer address=0x[a-z\d]+ size=\d+> @cache_hash=-?\d+ @ptr_cache_hash=-?\d+>/
        )
      end
      
    end
    
  end #after_init
  
end
