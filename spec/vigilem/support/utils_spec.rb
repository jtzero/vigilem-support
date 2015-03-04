require 'spec_helper'

require 'vigilem/support/utils'

describe Vigilem::Support::Utils do
  
  describe '::_offset_from_length' do
    it 'returns the amount that len is over the size of object' do
      expect(subject._offset_from_length('tests', 7)).to eql(2)
    end
    
    it 'returns 0 if the len passed in is lower than obj.size' do
      expect(subject._offset_from_length('tests', 3)).to eql(0)
    end
  end
  
  context 'ArrayAndStringUtils' do
    
    describe '#split_at' do
      Given(:str) { 'asdfqwer' }
      
      When(:result) { subject.split_at(str, 3) }
      
      Then { result == ['asd', 'fqwer'] }
    end
    
    describe '#split_on' do
      
      let(:str) { ['keycode   2', '=', 'U+0031', 'U+0021', 'U+0031', 'U+0031', 'VoidSymbol'] }
      
      it 'acts like String#split in which it removes the item split on' do
        expect(subject.split_on(str, 1)).to eql([['keycode   2'], ['U+0031', 'U+0021', 'U+0031', 'U+0031', 'VoidSymbol']])
      end
    end
    
    describe '#offset!, #offset' do
      
      context 'String param' do
        
        Given(:str) { 'tests' }
        Given(:orig_str) { str }
        
        context 'len < str' do
          
          describe '#offset!' do
            When(:result) { subject.offset!(str, 2) }
            
            Then { result == ['te', 0] }
            Then { str == 'sts' }
          end
          describe '#offset' do
            When(:result) { subject.offset(str, 2) }
            
            Then { result == ['te', 0] }
            Then { result.object_id != str.object_id }
            Then { str == orig_str }
          end
        end
        
        context 'len > str' do
          describe '#offset' do
            When(:result) { subject.offset!(str, 7) }
            
            Then { result == ['tests', 2] }
          end
          describe '#offset' do
            When(:result) { subject.offset(str, 7) }
            
            Then { result == ['tests', 2] }
            Then { str == orig_str }
          end
        end
        
      end
      
      context 'Array param' do
        
        Given(:ary) { ['a', 'b', 'c', 'd'] }
        Given(:orig_ary) { ary }
        
        context 'len < ary' do
          describe '#offset!' do
            When(:result) { subject.offset!(ary, 2) }
          
            Then { result == [['a', 'b'], 0] }
          end
          describe '#offset' do
            When(:result) { subject.offset(ary, 2) }
          
            Then { result == [['a', 'b'], 0] }
            Then { ary == orig_ary }
          end
        end
        
        context 'len > ary' do
          describe '#offset!' do
            When(:result) { subject.offset!(ary, 7) }
            
            Then { result == [['a', 'b', 'c', 'd'], 3] }
          end
          describe '#offset' do
            When(:result) { subject.offset(ary, 7) }
            
            Then { result == [['a', 'b', 'c', 'd'], 3] }
            Then { ary == orig_ary }
          end
        end
        
      end
    end
    
    describe '#unwrap_ary' do
      it 'pops the item off the array when there is only one item in it' do
        expect(described_class.unwrap_ary([1])).to eql(1)
      end
      
      it 'leaves the array as is if there is more than one item in it' do
        expect(described_class.unwrap_ary([1,2,3])).to eql([1,2,3])
      end
    end
    
    describe '#in_ranged_array?' do
      it 'is the number included in an array of ranged items' do
        expect(described_class.in_ranged_array?([0..12, 17..21], 18)).to be_truthy
      end
      
      it 'handles a mixed array of Integer and ranges' do
        expect(described_class.in_ranged_array?([0..12, 17, 19, 21], 19)).to be_truthy
      end
    end
    
  end
  
  context 'NumericUtils' do
    
    describe '#clamp' do
      it 'returns the lower bounds if lower than it' do
        expect(subject.clamp(-12, min: 0)).to eql(0)
      end
      
      it 'returns the upper bounds if greater than it' do
        expect(subject.clamp(15, max: 12)).to eql(12)
      end
      
      it 'returns the variable given in if between the limits' do
        expect(subject.clamp(5, min: 3, max: 12)).to eql(5)
      end
    end
    
    describe '#ceil_div' do
      Given(:num) { 10 }
      Given(:denom) { 7 }
      
      When(:result) { subject.ceil_div(num, denom) }
      
      Then { result == 2 }
    end
  end
  
  # @todo
  describe 'GemUtils' do
    
    describe '::data_dir' do
    
    end
    
    describe '::gem_path' do
    
    end
    
  end
  
  describe 'KernelUtils' do
    
    describe '#get_class' do
      
      before(:all) { TempClass = Class.new }
      
      it 'will return the objects class' do
        expect(described_class.get_class(TempClass.new)).to eql(TempClass)
      end
      
      it 'will the Class if given one' do
        expect(described_class.get_class(TempClass)).to eql(TempClass)
      end
    end
    
    describe '#send_all_or_no_args' do
      it %q<won't send any arguments if the arity == 0> do
        str = 'test'
        expect(described_class.send_all_or_no_args(str.method(:to_s), 'hmm', 'this shouldn\'t do anything')).to eql(str)
      end
    end
  end
  
  describe 'ObjectUtils' do
    describe '#_deep_dup' do
      
    end
    
    describe '#deep_dup' do
      
    end
    
    describe '#inspect_id' do
      
    end
    
    describe '#inspect_shell' do
      
    end
  end
  
end
