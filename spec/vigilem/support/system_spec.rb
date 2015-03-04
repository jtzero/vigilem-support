
require 'vigilem/support/system'

describe Vigilem::Support::System do
  
  describe '::`mask_name`' do
    it 'will respond_to? :mac?' do
      expect(described_class).to respond_to(:mac?)
    end
    
    it 'will respond_to? :linux?' do
      expect(described_class).to respond_to(:linux?)
    end
    
    it 'will respond_to? :windows?' do
      expect(described_class).to respond_to(:windows?)
    end
    
    it 'will respond_to? :bsd?' do
      expect(described_class).to respond_to(:bsd?)
    end
    
    it 'will respond_to? :nix?' do
      expect(described_class).to respond_to(:nix?)
    end
    
    it 'will respond_to? :aix?' do
      expect(described_class).to respond_to(:aix?)
    end
  end
end