require 'spec_helper'

require 'vigilem/support/transmutable_hash'

  # {:key1=>["a", "b", "c"], :key2=>["e", "f"], :key => "d" }
  # {:key1=>["a", "b", "c"], :key2=>["d", "e", "f"]} becomes 
  # {"a"=>:key1, "b"=>:key1, "c"=>:key1, "d"=>:key2, "e"=>:key2, "f"=>:key2 }
  # it will have a different object_id, because technically its a different hash
describe Vigilem::Support::TransmutableHash do
  Given(:hash_map) { described_class.new({:key1 => %w(a b c), :key2 => %w(e f), :key => 'd' }, 'default') }
  
  Given(:dump_key_hash) { 
                         {"keycode1"=>"Escape", ["shift", "keycode1"]=>"Escape", ["altgr", "keycode1"]=>"Escape", 
                          ["shift", "altgr", "keycode1"]=>"Escape", ["control", "keycode1"]=>"Escape", 
                          ["shift", "control", "keycode1"]=>"Escape", ["altgr", "control", "keycode1"]=>"Escape", 
                          ["shift", "altgr", "control", "keycode1"]=>"Escape", ["alt", "keycode1"]=>"Meta_Escape", 
                          ["shift","alt", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "keycode1"]=>"Meta_Escape", 
                          ["shift", "altgr", "alt", "keycode1"]=>"Meta_Escape", 
                          ["control", "alt", "keycode1"]=>"Meta_Escape", ["shift", "control", "alt", "keycode1"]=>"Meta_Escape"
                         } 
                        }
  
  
  describe '#invert' do
    When(:result) { hash_map.invert }
    
    Then { result == { "a" => :key1, "b" => :key1, "c" => :key1, "d" => :key, "e" => :key2, "f" => :key2 } }
    
    Then { hash_map.send(:_invert_cache_) == result } 
    
  end
  
  describe '#invert!' do
    Given(:original) { described_class.new({%w(this is a key) => :value, :key2=>["e", "f"], :key => "d"}) }
    Given(:hsh) { described_class.new({%w(this is a key) => :value, :key2=>["e", "f"], :key => "d"}) }
    
    it 'updates inplace the inversion' do
      hsh.invert!
      expect(hsh).to eql(original.invert)
      expect(hsh).not_to eql(original)
    end
     
  end
  
  describe '::fuse_vaue' do
    
    it 'concats values to when keys match' do
      hsh = {%w(this is a key) => :value, :key2=>["e", "f"], :key => "d"}
      expect(described_class.fuse_value(hsh, :key, 'my_value')).to eql(
        {["this", "is", "a", "key"]=>:value, :key2=>["e", "f"], :key=>["d", "my_value"]}
      )
    end
    
    it 'inserts arrays when keys match' do
      hsh = {%w(this is a key) => :value, :key2=>["e", "f"], :key => "d"}
      expect(described_class.fuse_value(hsh, :key2, ['my_value'])).to eql(
        {["this", "is", "a", "key"]=>:value, :key2=>["e", "f", ['my_value']], :key=>"d"}
      )
    end
    
    it 'acts like merge' do
      hsh = {%w(this is a key) => :value, :key2=>["e", "f"], :key => "d"}
      expect(described_class.fuse_value(hsh, %w(my new key), 'my_value')).to eql(
        {["this", "is", "a", "key"]=>:value, :key2=>["e", "f"], :key=>"d", ["my", "new", "key"]=>"my_value"}
      )
    end
    
    it 'acts like merge and wraps an array value' do
      hsh = {%w(this is a key) => :value, :key2=>["e", "f"], :key => "d"}
      expect(described_class.fuse_value(hsh, %w(my new key), ['my_value'])).to eql(
        {["this", "is", "a", "key"]=>:value, :key2=>["e", "f"], :key=>"d", ["my", "new", "key"]=>[["my_value"]]}
      )
    end
    
  end
  
  describe '::transmute' do
    
    it 'inverts the hash and splits up array values into keys' do
      hsh = described_class.transmute({:key => [1,2,3] })
      expect(hsh).to eql({1 => :key, 2 => :key, 3 => :key })
    end
    
    it 'inverts the hash and wraps Array keys to prevent split up' do
      hsh = described_class.transmute(
        {["this", "is", "a", "key"]=>:value, :key2=>["e", "f"], :key=>"d"}
      )
      
      expect(hsh).to eql(
        {:value=>[["this", "is", "a", "key"]], "e"=>:key2, "f"=>:key2, "d"=>:key}
      )
    end
    
    describe 'prevent invert!.invert from breaking down the hash' do
      it 'prevents Array keys from being split up on invert' do
        hsh = described_class.new(
          {["this", "is", "a", "key"]=>:value, :key2=>["e", "f"], :key=>"d"}
        )
        expect(hsh.invert!.invert).to eql(
          {["this", "is", "a", "key"]=>:value, :key2=>["e", "f"], :key=>"d"}
        )
      end
    end
  end

  context 'setting default' do
    
    describe 'values' do
      Given(:default_value) { 'default' }
      
      describe 'with #new(default_value),' do
        When(:instantiated) { described_class.new(default_value) }
        
        Then { expect(instantiated.default).to eql default_value }
        Then { expect(instantiated.invert_default).to eql default_value }
      end
      
      describe 'with #default=,' do
        When(:assigned_default) do
          sbj = described_class.new
          sbj.default = default_value
          sbj
        end
        
        Then { expect(assigned_default.default).to eql default_value }
        Then { expect(assigned_default.invert_default).to eql nil }
      end
      
      describe 'with #defaults=,' do
        When(:assigned_defaults) do
          sbj = described_class.new
          sbj.defaults = default_value
          sbj
        end
        
        Then { expect(assigned_defaults.defaults).to eql [default_value, default_value] }
      end
      
    end
    
    describe 'procs' do
      let(:proc) { lambda {|h,k| h[k] = Hash.new() }  }
      
      describe 'with #new(&proc),' do
        
        When(:instantiated) { described_class.new(&proc) }
        
        Then { expect(instantiated.default_proc).to eql proc }
        Then { expect(instantiated.invert_default_proc).to eql proc }
      end
      
      describe 'with #default_proc=,' do
        
        When(:assigned_default_proc) do
          sbj = described_class.new
          sbj.default_proc = proc
          sbj
        end
        
        Then { expect(assigned_default_proc.default_proc).to eql proc }
        Then { expect(assigned_default_proc.invert_default_proc).to eql nil }
      end
      
      describe 'with #default_procs=,' do
        When(:assigned_default_procs) do
          sbj = described_class.new
          sbj.default_procs = proc
          sbj
        end
        
        Then { expect(assigned_default_procs.default_procs).to eql [proc, proc] }
      end
    end
  end
end
