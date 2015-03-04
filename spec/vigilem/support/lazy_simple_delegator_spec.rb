require 'vigilem/support/lazy_simple_delegator'

describe Vigilem::Support::LazySimpleDelegator do
  
  class Dino
    def rawr!
      puts 'rawr!'
    end
  end
  
  context 'before __setobj__' do
    it %q<won't error with nil argument on instantiation> do
      expect { described_class.new() }.to_not raise_error
    end
  end
  
  subject { described_class.new() }
  
  let(:before___setobj___to_s) { subject.to_s }
  
  context 'after __setobj__' do
    
    let(:dino) { Dino.new }
    
    before(:each) do
      subject.__setobj__(dino)
    end
    
    it 'will not allow delegation to self' do
      expect { subject.__setobj__(subject) }.to raise_error(ArgumentError, 'cannot delegate to self')
    end
    
    it 'will have its own to_s unlike built in ruby delegate' do
      expect(subject.to_s).to eql before___setobj___to_s
    end
    
    it 'will have its own inspect unlike built in ruby delegate' do
      expect(subject.inspect).not_to eql dino.inspect
    end
    
    describe 'delegation' do
      it 'will take on object methods' do
        expect(subject).to respond_to :rawr!
      end
    end
    
    describe '#strict_eql=, #strict_eql?, #use_strict_eql' do
      
      context 'default behavior' do
        it '#strict_eql?, defaults to false' do
          expect(subject.strict_eql?).to be_falsey
        end
      end
      
      describe '#strict_eql=' do
        it %q<#strict_eql?, is true compares a delegator's __getobj__.object_id's> do
          subject.strict_eql = true
          expect(subject.eql?(SimpleDelegator.new(dino))).to be_truthy
        end
        
        it %q<#strict_eql?, is true compares a non Delegators object_id to this __getobj__.object_id> do
          subject.strict_eql = true
          expect(subject.eql?(dino)).to be_truthy
        end
      end
      
      describe '#use_strict_eql' do
        it %q<#use_strict_eql, sets strict_eql? to true and returns self> do
          expect(subject.use_strict_eql).to eql(subject) and
            an_object_having_attributes(:strict_eql? => true)
        end
      end
      
    end
    
  end
end