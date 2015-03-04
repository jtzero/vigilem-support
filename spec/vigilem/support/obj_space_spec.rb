require 'vigilem/support/obj_space'

describe Vigilem::Support::ObjSpace do
  
  class ObjSpaceHost
    extend Vigilem::Support::ObjSpace
  end
  
  class SubObjSpaceHost < ObjSpaceHost
  end
  
  after(:each) do
    ObjSpaceHost.all.replace([])
    SubObjSpaceHost.all.replace([])
  end
  
  describe '#all' do
    it 'defaults to []' do
      expect(ObjSpaceHost.all).to eql([])
    end
  end
  
  describe '#obj_register' do
    it 'returns the obj registered' do
      expect(ObjSpaceHost.obj_register('asdf')).to eql('asdf')
    end
    
    it 'adds the obj to #all' do
      ObjSpaceHost.obj_register('asdf')
      expect(ObjSpaceHost.all).to include('asdf')
    end
  end
  
  context 'subclass' do
    it %q<will add to the parent class #all> do
      SubObjSpaceHost.obj_register('test')
      expect(ObjSpaceHost.all).to include('test')
    end
    
    it 'will not list the parent class objects' do
      ObjSpaceHost.obj_register('asdf')
      expect(SubObjSpaceHost.all).not_to include('asdf')
    end
    
  end
  
end
