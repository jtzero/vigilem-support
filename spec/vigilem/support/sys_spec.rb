require 'spec_helper'

require 'vigilem/support/sys'

describe Vigilem::Support::Sys do
  describe '::sizeof' do
    describe 'returns the size of a string variable format' do
      Given 'ii' do
        Then { expect(described_class.sizeof(given_value)).to eql(8) }
      end
      
      it 'with number repeats' do
        expect(described_class.sizeof('CCSI32C')).to eql(133)
      end
      
      it 'with !' do
        expect(described_class.sizeof('CCS!I32C')).to eql(133)
      end
    end
  end
end
