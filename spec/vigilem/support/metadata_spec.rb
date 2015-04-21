require 'spec_helper'
require 'vigilem/support/metadata'

describe Vigilem::Support::Metadata do
  before :all do
    class Host
      include Vigilem::Support::Metadata
    end
  end
  
  after :all do
    Object.send(:remove_const, :Host) if Object.const_defined? :Host
  end
  
  describe '#metadata' do
    it 'defaults to empty Hash' do
      expect(Host.new.metadata).to eql({})
    end
  end
end