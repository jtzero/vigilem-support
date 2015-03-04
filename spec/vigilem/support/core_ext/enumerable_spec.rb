require 'vigilem/support/core_ext'

describe Enumerable do
  let(:object) { Object.new }
  
  context 'Array' do
    subject { ['b', 2, 'a', object, 'b'] }
    
    describe '#except' do
      it 'will remove objects that equal param not in place' do
        expect(subject.except('b')).to eql([2, 'a', object])
      end
    end
    
    describe '#except_at' do
      it 'will remove objects from index not in place' do
        expect(subject.except_at(1)).to eql(['b', 'a', object, 'b'])
      end
    end
  end
  
  context 'Hash' do
    subject { {'b' => 2, object => 'b', :test => 'yes' } }
    
    describe '#except' do
      it 'will remove key value pairs where the key equals param not in place' do
        expect(subject.except(object)).to eql({'b' => 2, :test => 'yes' })
      end
    end
    
    describe '#except_at' do
      it 'will remove objects from index not in place' do
        expect(subject.except_at(1)).to eql({'b' => 2, :test => 'yes' })
      end
    end
  end
  
end
