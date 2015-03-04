require 'spec_helper'

require 'vigilem/support/key_map'

describe Vigilem::Support::KeyMap do
  
  let(:cached_short_path) { File.expand_path('data/cached_short.kmap', File.dirname(__FILE__)) }
  let(:dump_keys_short_path) { File.expand_path('data/dump_keys_short.kmap', File.dirname(__FILE__)) }
  
  let(:dump_keys_lines) do
    ['keymaps 0-127',
     'keycode   1 = Escape',
     '        alt     keycode   1 = Meta_Escape',
     '        shift   alt     keycode   1 = Meta_Escape',
     'keycode   2 = one              exclam           one              one',
     '        alt     keycode   2 = Meta_one',
     '        shift   alt     keycode   2 = Meta_exclam',
     '        altgr   alt     keycode   2 = Meta_one']
  end
  
=begin @todo
  let(:dump_keys_lines) do
    ['keymaps 0-127',
     'keycode   1 = 0x001b',
     '        alt     keycode   1 = 0x081b',
     '        shift   alt     keycode   1 = 0x081b',
     'keycode   2 = 0x0031              0x0021           0x0031              0x0031',
     '        alt     keycode   2 = 0x0831',
     '        shift   alt     keycode   2 = 0x0821',
     '        altgr   alt     keycode   2 = 0x0831']
  end
=end
  
  let(:cached_lines) do
    ['keymaps 0-127',
    'keycode 1 = Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape',
    'keycode 10 = U+0039 U+0028 U+0039 U+0039 VoidSymbol VoidSymbol VoidSymbol VoidSymbol Meta_nine Meta_parenleft Meta_nine Meta_nine VoidSymbol VoidSymbol VoidSymbol VoidSymbol U+0039 U+0028 U+0039 U+0039 VoidSymbol VoidSymbol VoidSymbol VoidSymbol Meta_nine Meta_parenleft Meta_nine Meta_nine VoidSymbol VoidSymbol VoidSymbol VoidSymbol U+0039 U+0028 U+0039 U+0039 VoidSymbol VoidSymbol VoidSymbol VoidSymbol Meta_nine Meta_parenleft Meta_nine Meta_nine VoidSymbol VoidSymbol VoidSymbol VoidSymbol U+0039 U+0028 U+0039 U+0039 VoidSymbol VoidSymbol VoidSymbol VoidSymbol Meta_nine Meta_parenleft Meta_nine Meta_nine VoidSymbol VoidSymbol VoidSymbol VoidSymbol U+0039 U+0028 U+0039 U+0039 VoidSymbol VoidSymbol VoidSymbol VoidSymbol Meta_nine Meta_parenleft Meta_nine Meta_nine VoidSymbol VoidSymbol VoidSymbol VoidSymbol U+0039 U+0028 U+0039 U+0039 VoidSymbol VoidSymbol VoidSymbol VoidSymbol Meta_nine Meta_parenleft Meta_nine Meta_nine VoidSymbol VoidSymbol VoidSymbol VoidSymbol U+0039 U+0028 U+0039 U+0039 VoidSymbol VoidSymbol VoidSymbol VoidSymbol Meta_nine Meta_parenleft Meta_nine Meta_nine VoidSymbol VoidSymbol VoidSymbol VoidSymbol U+0039 U+0028 U+0039 U+0039 VoidSymbol VoidSymbol VoidSymbol VoidSymbol Meta_nine Meta_parenleft Meta_nine Meta_nine VoidSymbol VoidSymbol VoidSymbol VoidSymbol']
  end
  
  let(:cached_line) { 'keycode 1 = Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Escape Escape Escape Escape Escape Escape Escape Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape Meta_Escape' }
  
  let(:dump_keys_line1) { 'keycode   2 = one              exclam           one              one' }
  let(:dump_keys_line2) { 'alt     keycode   2 = Meta_one' }
  
  describe 'util #class_methods' do 
  
    describe '::modifier_combination' do
      it 'finds the modifier combination that fits into 121' do
        expect(described_class.modifier_combination(121)).to eql(["shift", "alt", "shiftl", "shiftr", "ctrll"])
      end
      it 'finds the modifier combination that fits into 7' do
        expect(described_class.modifier_combination(7)).to eql(["shift", "altgr", "control"])
      end
    end
  end
  
  describe 'parsing instance_methods' do
    
    describe '#parse_keymap_spec' do
      it 'will convert the keymap spec to an array of Integers and Ranges' do
        subject.parse_keymap_spec('keymaps 0-127')
        expect(subject.spec).to eql([0..127])
      end
    end
    
    context 'requiring parsed spec' do
    
      subject do
        km = described_class.new('VoidSymbol')
        km.parse_keymap_spec('keymaps 0-127')
        km
      end
      
      describe '#build_hash_from_full_table_line and ::build_hash_from_full_table_line' do
        
        let(:keycode) { cached_line.split('=').first.delete(' ') }
        
        let(:right_side) { cached_line.split('=').last.split(/\s/)[1..-1] }
          
        let(:result) { {"keycode1"=>"Escape", ["shift", "keycode1"]=>"Escape", 
          ["altgr", "keycode1"]=>"Escape", ["shift", "altgr", "keycode1"]=>"Escape", 
          ["control", "keycode1"]=>"Escape", ["shift", "control", "keycode1"]=>"Escape", 
          ["altgr", "control", "keycode1"]=>"Escape", ["shift", "altgr", "control", "keycode1"]=>"Escape", ["alt", "keycode1"]=>"Meta_Escape",
          ["shift", "alt", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "alt", "keycode1"]=>"Meta_Escape", 
          ["control", "alt", "keycode1"]=>"Meta_Escape", ["shift", "control", "alt", "keycode1"]=>"Meta_Escape", 
          ["altgr", "control", "alt", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "control", "alt", "keycode1"]=>"Meta_Escape", 
          ["shiftl", "keycode1"]=>"Escape", ["shift", "shiftl", "keycode1"]=>"Escape", ["altgr", "shiftl", "keycode1"]=>"Escape", 
          ["shift", "altgr", "shiftl", "keycode1"]=>"Escape", ["control", "shiftl", "keycode1"]=>"Escape", 
          ["shift", "control", "shiftl", "keycode1"]=>"Escape", ["altgr", "control", "shiftl", "keycode1"]=>"Escape", 
          ["shift", "altgr", "control", "shiftl", "keycode1"]=>"Escape", ["alt", "shiftl", "keycode1"]=>"Meta_Escape", 
          ["shift", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "keycode1"]=>"Meta_Escape", 
          ["shift", "altgr", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", 
          ["shift", "control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", 
          ["shift", "altgr", "control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["shiftr", "keycode1"]=>"Escape", 
          ["shift", "shiftr", "keycode1"]=>"Escape", ["altgr", "shiftr", "keycode1"]=>"Escape", ["shift", "altgr", "shiftr", "keycode1"]=>"Escape", 
          ["control", "shiftr", "keycode1"]=>"Escape", ["shift", "control", "shiftr", "keycode1"]=>"Escape", ["altgr", "control", "shiftr", "keycode1"]=>"Escape", 
          ["shift", "altgr", "control", "shiftr", "keycode1"]=>"Escape", ["alt", "shiftr", "keycode1"]=>"Meta_Escape", 
          ["shift", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftr", "keycode1"]=>"Meta_Escape", 
          ["shift", "altgr", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", 
          ["shift", "control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", 
          ["shift", "altgr", "control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["shiftl", "shiftr", "keycode1"]=>"Escape", 
          ["shift", "shiftl", "shiftr", "keycode1"]=>"Escape", ["altgr", "shiftl", "shiftr", "keycode1"]=>"Escape", 
          ["shift", "altgr", "shiftl", "shiftr", "keycode1"]=>"Escape", ["control", "shiftl", "shiftr", "keycode1"]=>"Escape", 
          ["shift", "control","shiftl", "shiftr", "keycode1"]=>"Escape", ["altgr", "control", "shiftl", "shiftr", "keycode1"]=>"Escape", 
          ["shift", "altgr", "control", "shiftl", "shiftr", "keycode1"]=>"Escape", ["alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", 
          ["shift", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", 
          ["shift", "altgr", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", 
          ["shift", "control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", 
          ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["ctrll", "keycode1"]=>"Escape", ["shift", "ctrll", "keycode1"]=>"Escape", 
          ["altgr", "ctrll", "keycode1"]=>"Escape", ["shift", "altgr", "ctrll", "keycode1"]=>"Escape", ["control", "ctrll", "keycode1"]=>"Escape", 
          ["shift", "control", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "ctrll", "keycode1"]=>"Escape", ["shift", "altgr", "control", "ctrll", "keycode1"]=>"Escape", 
          ["alt", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "ctrll", "keycode1"]=>"Meta_Escape", 
          ["shift", "altgr", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", 
          ["shift", "control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", 
          ["shift", "altgr", "control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["shiftl", "ctrll", "keycode1"]=>"Escape", 
          ["shift", "shiftl", "ctrll", "keycode1"]=>"Escape", ["altgr", "shiftl", "ctrll", "keycode1"]=>"Escape", ["shift", "altgr", "shiftl", "ctrll", "keycode1"]=>"Escape", 
          ["control", "shiftl", "ctrll", "keycode1"]=>"Escape", ["shift", "control", "shiftl", "ctrll", "keycode1"]=>"Escape", 
          ["altgr", "control", "shiftl", "ctrll", "keycode1"]=>"Escape", ["shift", "altgr", "control", "shiftl", "ctrll", "keycode1"]=>"Escape", 
          ["alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
          ["altgr", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
          ["control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
          ["altgr", "control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
          ["shiftr", "ctrll", "keycode1"]=>"Escape", ["shift", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "shiftr", "ctrll", "keycode1"]=>"Escape", 
          ["shift", "altgr", "shiftr", "ctrll", "keycode1"]=>"Escape", ["control", "shiftr", "ctrll", "keycode1"]=>"Escape", 
          ["shift", "control", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "shiftr", "ctrll", "keycode1"]=>"Escape", 
          ["shift", "altgr", "control", "shiftr", "ctrll", "keycode1"]=>"Escape", ["alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
          ["shift", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
          ["shift", "altgr", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
          ["shift", "control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
          ["shift", "altgr", "control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
          ["shift", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
          ["shift", "altgr", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
          ["shift", "control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
          ["shift", "altgr", "control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["alt", "shiftl", "shiftr","ctrll", "keycode1"]=>"Meta_Escape", 
          ["shift", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
          ["shift", "altgr", "alt", "shiftl", "shiftr", "ctrll","keycode1"]=>"Meta_Escape", ["control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
          ["shift", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
          ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape"}}
        
        context 'class_method' do
          it 'converts the right side of a keymap into a hash' do
            expect(described_class.build_hash_from_full_table_line(right_side, keycode)).to eql(result)
          end
        end
        context 'instance_method' do
          it 'converts the right side of a keymap into a hash' do
            subject.build_hash_from_full_table_line(right_side, keycode)
            expect(subject).to eql(result)
          end
        end
      end
      
      describe '#parse_expression_block' do
        
        it 'converts a cached expresssion block into TransmutableHash' do
          subject.parse_expression_block(cached_line)
          expect(subject).to eql({"keycode1"=>"Escape", ["shift", "keycode1"]=>"Escape", ["altgr", "keycode1"]=>"Escape", 
              ["shift", "altgr", "keycode1"]=>"Escape", ["control", "keycode1"]=>"Escape", ["shift", "control", "keycode1"]=>"Escape", 
              ["altgr", "control", "keycode1"]=>"Escape", ["shift", "altgr", "control", "keycode1"]=>"Escape", 
              ["alt", "keycode1"]=>"Meta_Escape",["shift", "alt", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "alt", "keycode1"]=>"Meta_Escape", ["control", "alt", "keycode1"]=>"Meta_Escape", 
              ["shift", "control", "alt", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "control", "alt", "keycode1"]=>"Meta_Escape", ["shiftl", "keycode1"]=>"Escape", 
              ["shift", "shiftl", "keycode1"]=>"Escape", ["altgr", "shiftl", "keycode1"]=>"Escape", 
              ["shift", "altgr", "shiftl", "keycode1"]=>"Escape", ["control", "shiftl", "keycode1"]=>"Escape", 
              ["shift", "control", "shiftl", "keycode1"]=>"Escape", ["altgr", "control", "shiftl", "keycode1"]=>"Escape", 
              ["shift", "altgr", "control", "shiftl", "keycode1"]=>"Escape", ["alt", "shiftl", "keycode1"]=>"Meta_Escape", 
              ["shift", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", 
              ["shift", "control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["shiftr", "keycode1"]=>"Escape", 
              ["shift", "shiftr", "keycode1"]=>"Escape", ["altgr", "shiftr", "keycode1"]=>"Escape", ["shift", "altgr", "shiftr", "keycode1"]=>"Escape", 
              ["control", "shiftr", "keycode1"]=>"Escape", ["shift", "control", "shiftr", "keycode1"]=>"Escape", 
              ["altgr", "control", "shiftr", "keycode1"]=>"Escape", ["shift", "altgr", "control", "shiftr", "keycode1"]=>"Escape", 
              ["alt", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "alt", "shiftr", "keycode1"]=>"Meta_Escape", 
              ["altgr", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "alt", "shiftr", "keycode1"]=>"Meta_Escape", 
              ["control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", 
              ["altgr", "control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", 
              ["shiftl", "shiftr", "keycode1"]=>"Escape", ["shift", "shiftl", "shiftr", "keycode1"]=>"Escape", 
              ["altgr", "shiftl", "shiftr", "keycode1"]=>"Escape", ["shift", "altgr", "shiftl", "shiftr", "keycode1"]=>"Escape", 
              ["control", "shiftl", "shiftr", "keycode1"]=>"Escape", ["shift", "control","shiftl", "shiftr", "keycode1"]=>"Escape", 
              ["altgr", "control", "shiftl", "shiftr", "keycode1"]=>"Escape", ["shift", "altgr", "control", "shiftl", "shiftr", "keycode1"]=>"Escape", 
              ["alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", 
              ["altgr", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", 
              ["control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", 
              ["altgr", "control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["ctrll", "keycode1"]=>"Escape", 
              ["shift", "ctrll", "keycode1"]=>"Escape", ["altgr", "ctrll", "keycode1"]=>"Escape", ["shift", "altgr", "ctrll", "keycode1"]=>"Escape", 
              ["control", "ctrll", "keycode1"]=>"Escape", ["shift", "control", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "altgr", "control", "ctrll", "keycode1"]=>"Escape", ["alt", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["shiftl", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "shiftl", "ctrll", "keycode1"]=>"Escape", ["altgr", "shiftl", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "altgr", "shiftl", "ctrll", "keycode1"]=>"Escape", ["control", "shiftl", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "control", "shiftl", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "shiftl", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "altgr", "control", "shiftl", "ctrll", "keycode1"]=>"Escape", ["alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "altgr", "shiftr", "ctrll", "keycode1"]=>"Escape", ["control", "shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "control", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "altgr", "control", "shiftr", "ctrll", "keycode1"]=>"Escape", ["alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "altgr", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "altgr", "control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["alt", "shiftl", "shiftr","ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "alt", "shiftl", "shiftr", "ctrll","keycode1"]=>"Meta_Escape", ["control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape"})
        end
        
        it 'converts a dump_keys line with multiple post keysyms into TransmutableHash' do
          subject.parse_expression_block(dump_keys_line1)
          expect(subject).to eql({"keycode2"=>"one", ["shift", "keycode2"]=>"exclam", ["altgr", "keycode2"]=>"one", ["shift", "altgr", "keycode2"]=>"one"})
        end
        
        it 'converts a dump_keys line with pre keysyms into TransmutableHash' do
          subject.parse_expression_block(dump_keys_line2)
          expect(subject).to eql({["alt", "keycode2"] =>"Meta_one"})
        end
      end
      
      describe '#parse_keymap_expressions' do
        
        it 'parses multiple keymap expressions' do
          subject.parse_keymap_expressions(*cached_lines)
          expect(subject).to eql({"keycode1"=>"Escape", ["shift", "keycode1"]=>"Escape", ["altgr", "keycode1"]=>"Escape", ["shift", "altgr", "keycode1"]=>"Escape",
              ["control", "keycode1"]=>"Escape", ["shift", "control", "keycode1"]=>"Escape", ["altgr", "control", "keycode1"]=>"Escape", 
              ["shift", "altgr", "control", "keycode1"]=>"Escape", ["alt", "keycode1"]=>"Meta_Escape", ["shift", "alt", "keycode1"]=>"Meta_Escape", 
              ["altgr", "alt", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "alt", "keycode1"]=>"Meta_Escape", ["control", "alt", "keycode1"]=>"Meta_Escape", 
              ["shift", "control", "alt", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "control", "alt", "keycode1"]=>"Meta_Escape", ["shiftl", "keycode1"]=>"Escape", ["shift", "shiftl", "keycode1"]=>"Escape", 
              ["altgr", "shiftl", "keycode1"]=>"Escape", ["shift", "altgr", "shiftl", "keycode1"]=>"Escape", ["control", "shiftl", "keycode1"]=>"Escape", 
              ["shift", "control", "shiftl", "keycode1"]=>"Escape", ["altgr", "control", "shiftl", "keycode1"]=>"Escape", 
              ["shift", "altgr", "control", "shiftl", "keycode1"]=>"Escape", ["alt", "shiftl", "keycode1"]=>"Meta_Escape", 
              ["shift", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", 
              ["shift", "control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["shiftr", "keycode1"]=>"Escape", ["shift", "shiftr", "keycode1"]=>"Escape", 
              ["altgr", "shiftr", "keycode1"]=>"Escape", ["shift", "altgr", "shiftr", "keycode1"]=>"Escape", ["control", "shiftr", "keycode1"]=>"Escape", 
              ["shift", "control", "shiftr", "keycode1"]=>"Escape", ["altgr", "control", "shiftr", "keycode1"]=>"Escape", 
              ["shift", "altgr", "control", "shiftr", "keycode1"]=>"Escape", ["alt", "shiftr", "keycode1"]=>"Meta_Escape", 
              ["shift", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftr", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", 
              ["shift", "control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["shiftl", "shiftr", "keycode1"]=>"Escape", 
              ["shift", "shiftl", "shiftr", "keycode1"]=>"Escape", ["altgr", "shiftl", "shiftr", "keycode1"]=>"Escape", 
              ["shift", "altgr", "shiftl", "shiftr", "keycode1"]=>"Escape", ["control", "shiftl", "shiftr", "keycode1"]=>"Escape", 
              ["shift", "control", "shiftl", "shiftr", "keycode1"]=>"Escape", ["altgr", "control", "shiftl", "shiftr", "keycode1"]=>"Escape", 
              ["shift", "altgr", "control", "shiftl", "shiftr", "keycode1"]=>"Escape", ["alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", 
              ["shift", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftl", "shiftr","keycode1"]=>"Meta_Escape", 
              ["shift", "control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["ctrll", "keycode1"]=>"Escape", ["shift", "ctrll", "keycode1"]=>"Escape", 
              ["altgr", "ctrll", "keycode1"]=>"Escape", ["shift", "altgr", "ctrll", "keycode1"]=>"Escape", ["control", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "control", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "altgr", "control", "ctrll", "keycode1"]=>"Escape", ["alt", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["shiftl", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "shiftl", "ctrll", "keycode1"]=>"Escape", ["altgr", "shiftl", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "altgr", "shiftl", "ctrll", "keycode1"]=>"Escape", ["control", "shiftl", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "control", "shiftl", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "shiftl", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "altgr", "control", "shiftl", "ctrll", "keycode1"]=>"Escape", ["alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "alt", "shiftl","ctrll", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "altgr", "shiftr", "ctrll", "keycode1"]=>"Escape", ["control", "shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "control", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "altgr", "control", "shiftr", "ctrll", "keycode1"]=>"Escape", ["alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "altgr", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
              ["shift", "altgr", "control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
              ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape",
              "keycode10"=>"U+0039", ["shift", "keycode10"]=>"U+0028", ["altgr", "keycode10"]=>"U+0039", ["shift", "altgr", "keycode10"]=>"U+0039", 
              ["control", "keycode10"]=>"VoidSymbol", ["shift", "control", "keycode10"]=>"VoidSymbol", ["altgr", "control", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "keycode10"]=>"VoidSymbol", ["alt", "keycode10"]=>"Meta_nine", ["shift", "alt", "keycode10"]=>"Meta_parenleft", 
              ["altgr", "alt", "keycode10"]=>"Meta_nine", ["shift", "altgr", "alt", "keycode10"]=>"Meta_nine", ["control", "alt", "keycode10"]=>"VoidSymbol", 
              ["shift", "control", "alt", "keycode10"]=>"VoidSymbol", ["altgr", "control", "alt", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "alt", "keycode10"]=>"VoidSymbol", ["shiftl", "keycode10"]=>"U+0039", ["shift", "shiftl", "keycode10"]=>"U+0028", 
              ["altgr", "shiftl", "keycode10"]=>"U+0039", ["shift", "altgr", "shiftl", "keycode10"]=>"U+0039", ["control", "shiftl", "keycode10"]=>"VoidSymbol", 
              ["shift", "control", "shiftl", "keycode10"]=>"VoidSymbol", ["altgr", "control", "shiftl", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "shiftl", "keycode10"]=>"VoidSymbol", ["alt", "shiftl", "keycode10"]=>"Meta_nine", 
              ["shift", "alt", "shiftl", "keycode10"]=>"Meta_parenleft", ["altgr", "alt", "shiftl", "keycode10"]=>"Meta_nine", 
              ["shift", "altgr", "alt", "shiftl", "keycode10"]=>"Meta_nine", ["control", "alt", "shiftl", "keycode10"]=>"VoidSymbol", 
              ["shift", "control", "alt", "shiftl", "keycode10"]=>"VoidSymbol", ["altgr", "control", "alt", "shiftl", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "alt", "shiftl", "keycode10"]=>"VoidSymbol", ["shiftr", "keycode10"]=>"U+0039", ["shift", "shiftr", "keycode10"]=>"U+0028", 
              ["altgr", "shiftr", "keycode10"]=>"U+0039", ["shift", "altgr", "shiftr", "keycode10"]=>"U+0039", ["control", "shiftr", "keycode10"]=>"VoidSymbol", 
              ["shift", "control", "shiftr", "keycode10"]=>"VoidSymbol", ["altgr", "control", "shiftr", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "shiftr", "keycode10"]=>"VoidSymbol", ["alt", "shiftr", "keycode10"]=>"Meta_nine", 
              ["shift", "alt", "shiftr", "keycode10"]=>"Meta_parenleft", ["altgr", "alt", "shiftr", "keycode10"]=>"Meta_nine", 
              ["shift", "altgr", "alt", "shiftr", "keycode10"]=>"Meta_nine", ["control", "alt", "shiftr", "keycode10"]=>"VoidSymbol", 
              ["shift", "control", "alt", "shiftr", "keycode10"]=>"VoidSymbol", ["altgr", "control", "alt", "shiftr", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "alt", "shiftr", "keycode10"]=>"VoidSymbol", ["shiftl", "shiftr", "keycode10"]=>"U+0039", 
              ["shift", "shiftl", "shiftr", "keycode10"]=>"U+0028", ["altgr", "shiftl", "shiftr", "keycode10"]=>"U+0039", 
              ["shift", "altgr", "shiftl", "shiftr", "keycode10"]=>"U+0039", ["control", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", 
              ["shift", "control", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", ["altgr", "control", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", ["alt", "shiftl", "shiftr", "keycode10"]=>"Meta_nine", 
              ["shift", "alt", "shiftl", "shiftr", "keycode10"]=>"Meta_parenleft", ["altgr", "alt", "shiftl", "shiftr", "keycode10"]=>"Meta_nine", 
              ["shift", "altgr", "alt", "shiftl", "shiftr", "keycode10"]=>"Meta_nine", ["control", "alt", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol",
              ["shift", "control", "alt", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", ["altgr", "control", "alt", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", ["ctrll", "keycode10"]=>"U+0039", ["shift", "ctrll", "keycode10"]=>"U+0028", 
              ["altgr", "ctrll", "keycode10"]=>"U+0039", ["shift", "altgr", "ctrll", "keycode10"]=>"U+0039", ["control", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "control", "ctrll", "keycode10"]=>"VoidSymbol", ["altgr", "control", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "ctrll", "keycode10"]=>"VoidSymbol", ["alt", "ctrll", "keycode10"]=>"Meta_nine", 
              ["shift", "alt", "ctrll", "keycode10"]=>"Meta_parenleft", ["altgr", "alt", "ctrll", "keycode10"]=>"Meta_nine", 
              ["shift", "altgr", "alt", "ctrll", "keycode10"]=>"Meta_nine", ["control", "alt", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "control", "alt", "ctrll", "keycode10"]=>"VoidSymbol", ["altgr", "control", "alt", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "alt", "ctrll", "keycode10"]=>"VoidSymbol", ["shiftl", "ctrll", "keycode10"]=>"U+0039", 
              ["shift", "shiftl", "ctrll", "keycode10"]=>"U+0028", ["altgr", "shiftl", "ctrll", "keycode10"]=>"U+0039", 
              ["shift", "altgr", "shiftl", "ctrll", "keycode10"]=>"U+0039", ["control", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "control", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", ["altgr", "control", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", ["alt", "shiftl", "ctrll", "keycode10"]=>"Meta_nine", 
              ["shift", "alt", "shiftl", "ctrll", "keycode10"]=>"Meta_parenleft", ["altgr", "alt", "shiftl", "ctrll", "keycode10"]=>"Meta_nine", 
              ["shift", "altgr", "alt", "shiftl", "ctrll", "keycode10"]=>"Meta_nine", ["control", "alt", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "control", "alt", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", ["altgr", "control", "alt", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "alt", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", ["shiftr", "ctrll", "keycode10"]=>"U+0039", 
              ["shift", "shiftr", "ctrll", "keycode10"]=>"U+0028", ["altgr", "shiftr", "ctrll", "keycode10"]=>"U+0039", 
              ["shift", "altgr", "shiftr", "ctrll", "keycode10"]=>"U+0039", ["control", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "control", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["altgr", "control", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["alt", "shiftr", "ctrll", "keycode10"]=>"Meta_nine", 
              ["shift", "alt", "shiftr", "ctrll", "keycode10"]=>"Meta_parenleft", ["altgr", "alt", "shiftr", "ctrll", "keycode10"]=>"Meta_nine", 
              ["shift", "altgr", "alt", "shiftr", "ctrll", "keycode10"]=>"Meta_nine", ["control", "alt", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "control", "alt", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["altgr", "control", "alt", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "alt", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["shiftl", "shiftr", "ctrll", "keycode10"]=>"U+0039", 
              ["shift", "shiftl", "shiftr", "ctrll", "keycode10"]=>"U+0028", ["altgr", "shiftl", "shiftr", "ctrll", "keycode10"]=>"U+0039", 
              ["shift", "altgr", "shiftl", "shiftr", "ctrll", "keycode10"]=>"U+0039", ["control", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "control", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["altgr", "control", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"Meta_nine", 
              ["shift", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"Meta_parenleft", ["altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"Meta_nine", 
              ["shift", "altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"Meta_nine", ["control", "alt","shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", 
              ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol"})
        end
      end
      
    end
  end #requiring
  
  describe 'parsing class methods' do
  
    describe '::load_string' do
      
      let(:cached_str) { cached_lines.join("\n") + "\n" }
      let(:dump_keys_str) { dump_keys_lines.join("\n") + "\n" }
      
      it 'converts cached_lines of a cache file into KeyMap class' do
        arg = described_class.load_string(cached_str)
        expect(arg).to eql({"keycode1"=>"Escape", ["shift", "keycode1"]=>"Escape", ["altgr", "keycode1"]=>"Escape", 
            ["shift", "altgr", "keycode1"]=>"Escape", ["control", "keycode1"]=>"Escape", ["shift", "control", "keycode1"]=>"Escape", 
            ["altgr", "control", "keycode1"]=>"Escape", ["shift", "altgr", "control", "keycode1"]=>"Escape", ["alt", "keycode1"]=>"Meta_Escape",
            ["shift", "alt", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "alt", "keycode1"]=>"Meta_Escape", 
            ["control", "alt", "keycode1"]=>"Meta_Escape", ["shift", "control", "alt", "keycode1"]=>"Meta_Escape", 
            ["altgr", "control", "alt", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "control", "alt", "keycode1"]=>"Meta_Escape", 
            ["shiftl", "keycode1"]=>"Escape", ["shift", "shiftl", "keycode1"]=>"Escape", ["altgr", "shiftl", "keycode1"]=>"Escape", 
            ["shift", "altgr", "shiftl", "keycode1"]=>"Escape", ["control", "shiftl", "keycode1"]=>"Escape", 
            ["shift", "control", "shiftl", "keycode1"]=>"Escape", ["altgr", "control", "shiftl", "keycode1"]=>"Escape", 
            ["shift", "altgr", "control", "shiftl", "keycode1"]=>"Escape", ["alt", "shiftl", "keycode1"]=>"Meta_Escape", 
            ["shift", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "keycode1"]=>"Meta_Escape", 
            ["shift", "altgr", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", 
            ["shift", "control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", 
            ["shift", "altgr", "control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["shiftr", "keycode1"]=>"Escape", 
            ["shift", "shiftr", "keycode1"]=>"Escape", ["altgr", "shiftr", "keycode1"]=>"Escape", ["shift", "altgr", "shiftr", "keycode1"]=>"Escape", 
            ["control", "shiftr", "keycode1"]=>"Escape", ["shift", "control", "shiftr", "keycode1"]=>"Escape", 
            ["altgr", "control", "shiftr", "keycode1"]=>"Escape", ["shift", "altgr", "control", "shiftr", "keycode1"]=>"Escape", 
            ["alt", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "alt", "shiftr", "keycode1"]=>"Meta_Escape", 
            ["altgr", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "alt", "shiftr", "keycode1"]=>"Meta_Escape", 
            ["control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", 
            ["altgr", "control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", 
            ["shiftl", "shiftr", "keycode1"]=>"Escape", ["shift", "shiftl", "shiftr", "keycode1"]=>"Escape", ["altgr", "shiftl", "shiftr", "keycode1"]=>"Escape", 
            ["shift", "altgr", "shiftl", "shiftr", "keycode1"]=>"Escape", ["control", "shiftl", "shiftr", "keycode1"]=>"Escape", 
            ["shift", "control","shiftl", "shiftr", "keycode1"]=>"Escape", ["altgr", "control", "shiftl", "shiftr", "keycode1"]=>"Escape", 
            ["shift", "altgr", "control", "shiftl", "shiftr", "keycode1"]=>"Escape", ["alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", 
            ["shift", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", 
            ["shift", "altgr", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", 
            ["shift", "control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", 
            ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["ctrll", "keycode1"]=>"Escape", 
            ["shift", "ctrll", "keycode1"]=>"Escape", ["altgr", "ctrll", "keycode1"]=>"Escape", ["shift", "altgr", "ctrll", "keycode1"]=>"Escape", 
            ["control", "ctrll", "keycode1"]=>"Escape", ["shift", "control", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "ctrll", "keycode1"]=>"Escape", 
            ["shift", "altgr", "control", "ctrll", "keycode1"]=>"Escape", ["alt", "ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "altgr", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "altgr", "control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["shiftl", "ctrll", "keycode1"]=>"Escape", 
            ["shift", "shiftl", "ctrll", "keycode1"]=>"Escape", ["altgr", "shiftl", "ctrll", "keycode1"]=>"Escape", 
            ["shift", "altgr", "shiftl", "ctrll", "keycode1"]=>"Escape", ["control", "shiftl", "ctrll", "keycode1"]=>"Escape", 
            ["shift", "control", "shiftl", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "shiftl", "ctrll", "keycode1"]=>"Escape", 
            ["shift", "altgr", "control", "shiftl", "ctrll", "keycode1"]=>"Escape", ["alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "altgr", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "altgr", "control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["shiftr", "ctrll", "keycode1"]=>"Escape", 
            ["shift", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "shiftr", "ctrll", "keycode1"]=>"Escape", 
            ["shift", "altgr", "shiftr", "ctrll", "keycode1"]=>"Escape", ["control", "shiftr", "ctrll", "keycode1"]=>"Escape", 
            ["shift", "control", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "shiftr", "ctrll", "keycode1"]=>"Escape", 
            ["shift", "altgr", "control", "shiftr", "ctrll", "keycode1"]=>"Escape", ["alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "altgr", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "altgr", "control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
            ["shift", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
            ["shift", "altgr", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
            ["shift", "control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", 
            ["shift", "altgr", "control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["alt", "shiftl", "shiftr","ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "altgr", "alt", "shiftl", "shiftr", "ctrll","keycode1"]=>"Meta_Escape", ["control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", 
            ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", "keycode10"=>"U+0039", ["shift", "keycode10"]=>"U+0028", 
            ["altgr", "keycode10"]=>"U+0039", ["shift", "altgr", "keycode10"]=>"U+0039", ["control", "keycode10"]=>"VoidSymbol", ["shift", "control", "keycode10"]=>"VoidSymbol",
            ["altgr", "control", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "keycode10"]=>"VoidSymbol", ["alt", "keycode10"]=>"Meta_nine", 
            ["shift", "alt", "keycode10"]=>"Meta_parenleft", ["altgr", "alt", "keycode10"]=>"Meta_nine", ["shift", "altgr", "alt", "keycode10"]=>"Meta_nine", 
            ["control", "alt", "keycode10"]=>"VoidSymbol", ["shift", "control", "alt", "keycode10"]=>"VoidSymbol", ["altgr", "control", "alt", "keycode10"]=>"VoidSymbol", 
            ["shift", "altgr", "control", "alt", "keycode10"]=>"VoidSymbol", ["shiftl", "keycode10"]=>"U+0039", ["shift", "shiftl", "keycode10"]=>"U+0028", 
            ["altgr", "shiftl", "keycode10"]=>"U+0039", ["shift", "altgr", "shiftl", "keycode10"]=>"U+0039", ["control", "shiftl", "keycode10"]=>"VoidSymbol", 
            ["shift", "control", "shiftl", "keycode10"]=>"VoidSymbol", ["altgr", "control", "shiftl", "keycode10"]=>"VoidSymbol", 
            ["shift", "altgr", "control", "shiftl", "keycode10"]=>"VoidSymbol", ["alt", "shiftl", "keycode10"]=>"Meta_nine",["shift", "alt", "shiftl", "keycode10"]=>"Meta_parenleft", 
            ["altgr", "alt", "shiftl", "keycode10"]=>"Meta_nine", ["shift", "altgr", "alt", "shiftl", "keycode10"]=>"Meta_nine", ["control", "alt", "shiftl", "keycode10"]=>"VoidSymbol", 
            ["shift", "control", "alt", "shiftl", "keycode10"]=>"VoidSymbol", ["altgr", "control", "alt", "shiftl", "keycode10"]=>"VoidSymbol", 
            ["shift", "altgr", "control", "alt", "shiftl", "keycode10"]=>"VoidSymbol", ["shiftr", "keycode10"]=>"U+0039", ["shift", "shiftr", "keycode10"]=>"U+0028", 
            ["altgr", "shiftr", "keycode10"]=>"U+0039", ["shift", "altgr", "shiftr", "keycode10"]=>"U+0039", ["control", "shiftr", "keycode10"]=>"VoidSymbol", 
            ["shift", "control", "shiftr", "keycode10"]=>"VoidSymbol", ["altgr", "control", "shiftr", "keycode10"]=>"VoidSymbol", 
            ["shift", "altgr", "control", "shiftr", "keycode10"]=>"VoidSymbol", ["alt", "shiftr", "keycode10"]=>"Meta_nine", ["shift", "alt", "shiftr", "keycode10"]=>"Meta_parenleft", 
            ["altgr", "alt", "shiftr", "keycode10"]=>"Meta_nine", ["shift", "altgr", "alt", "shiftr", "keycode10"]=>"Meta_nine", ["control", "alt", "shiftr", "keycode10"]=>"VoidSymbol", 
            ["shift", "control", "alt", "shiftr", "keycode10"]=>"VoidSymbol", ["altgr", "control", "alt", "shiftr", "keycode10"]=>"VoidSymbol", 
            ["shift", "altgr", "control", "alt", "shiftr", "keycode10"]=>"VoidSymbol", ["shiftl", "shiftr", "keycode10"]=>"U+0039", ["shift", "shiftl", "shiftr", "keycode10"]=>"U+0028", 
            ["altgr", "shiftl", "shiftr", "keycode10"]=>"U+0039", ["shift", "altgr", "shiftl", "shiftr", "keycode10"]=>"U+0039", ["control", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", 
            ["shift", "control", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", ["altgr", "control", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", 
            ["shift", "altgr", "control", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", ["alt", "shiftl", "shiftr", "keycode10"]=>"Meta_nine", 
            ["shift", "alt", "shiftl", "shiftr", "keycode10"]=>"Meta_parenleft", ["altgr", "alt", "shiftl", "shiftr", "keycode10"]=>"Meta_nine", 
            ["shift", "altgr", "alt", "shiftl", "shiftr", "keycode10"]=>"Meta_nine", ["control", "alt", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", 
            ["shift", "control", "alt", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", ["altgr", "control", "alt", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", 
            ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", ["ctrll", "keycode10"]=>"U+0039", ["shift", "ctrll", "keycode10"]=>"U+0028", 
            ["altgr", "ctrll", "keycode10"]=>"U+0039", ["shift", "altgr", "ctrll", "keycode10"]=>"U+0039", ["control", "ctrll", "keycode10"]=>"VoidSymbol", 
            ["shift", "control", "ctrll", "keycode10"]=>"VoidSymbol", ["altgr", "control", "ctrll", "keycode10"]=>"VoidSymbol", 
            ["shift", "altgr", "control", "ctrll", "keycode10"]=>"VoidSymbol", ["alt", "ctrll", "keycode10"]=>"Meta_nine", ["shift", "alt", "ctrll", "keycode10"]=>"Meta_parenleft", 
            ["altgr", "alt", "ctrll", "keycode10"]=>"Meta_nine", ["shift", "altgr", "alt", "ctrll", "keycode10"]=>"Meta_nine", 
            ["control", "alt", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "control", "alt", "ctrll", "keycode10"]=>"VoidSymbol", 
            ["altgr", "control", "alt", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "ctrll", "keycode10"]=>"VoidSymbol", 
            ["shiftl", "ctrll", "keycode10"]=>"U+0039", ["shift", "shiftl", "ctrll", "keycode10"]=>"U+0028", ["altgr", "shiftl", "ctrll", "keycode10"]=>"U+0039", 
            ["shift", "altgr", "shiftl", "ctrll", "keycode10"]=>"U+0039", ["control", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", 
            ["shift", "control", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", ["altgr", "control", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", 
            ["shift", "altgr", "control", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", ["alt", "shiftl", "ctrll", "keycode10"]=>"Meta_nine", 
            ["shift", "alt", "shiftl","ctrll", "keycode10"]=>"Meta_parenleft", ["altgr", "alt", "shiftl", "ctrll", "keycode10"]=>"Meta_nine", 
            ["shift", "altgr", "alt", "shiftl", "ctrll", "keycode10"]=>"Meta_nine", ["control", "alt", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", 
            ["shift", "control", "alt", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", ["altgr", "control", "alt", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", 
            ["shift", "altgr", "control", "alt", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", ["shiftr", "ctrll", "keycode10"]=>"U+0039", 
            ["shift", "shiftr", "ctrll", "keycode10"]=>"U+0028", ["altgr", "shiftr", "ctrll", "keycode10"]=>"U+0039", ["shift", "altgr", "shiftr", "ctrll", "keycode10"]=>"U+0039", 
            ["control", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "control", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", 
            ["altgr", "control", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol",
            ["alt", "shiftr", "ctrll", "keycode10"]=>"Meta_nine", ["shift", "alt", "shiftr", "ctrll", "keycode10"]=>"Meta_parenleft", 
            ["altgr", "alt", "shiftr", "ctrll", "keycode10"]=>"Meta_nine", ["shift", "altgr", "alt", "shiftr", "ctrll", "keycode10"]=>"Meta_nine", 
            ["control", "alt", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "control", "alt", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", 
            ["altgr", "control", "alt", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", 
            ["shiftl", "shiftr", "ctrll", "keycode10"]=>"U+0039", ["shift", "shiftl", "shiftr", "ctrll", "keycode10"]=>"U+0028", 
            ["altgr", "shiftl", "shiftr", "ctrll", "keycode10"]=>"U+0039", ["shift", "altgr", "shiftl", "shiftr", "ctrll", "keycode10"]=>"U+0039", 
            ["control", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "control", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", 
            ["altgr", "control", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", 
            ["alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"Meta_nine", ["shift", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"Meta_parenleft", 
            ["altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"Meta_nine", ["shift", "altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"Meta_nine", 
            ["control", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", 
            ["altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol"})
      end
      
      it 'converts cached_lines of a dumpkeys output into KeyMap class' do
        arg = described_class.load_string(dump_keys_str)
        expect(arg).to eql({"keycode1"=>"Escape", ["alt", "keycode1"]=>"Meta_Escape", ["shift", "alt", "keycode1"]=>"Meta_Escape",
                            "keycode2"=>"one", ["shift", "keycode2"]=>"exclam", ["altgr", "keycode2"]=>"one", ["shift", "altgr", "keycode2"]=>"one", 
                            ["alt", "keycode2"]=>"Meta_one", ["shift", "alt", "keycode2"]=>"Meta_exclam", ["altgr", "alt", "keycode2"]=>"Meta_one"})
      end
    end
    
    describe '::load_file' do
      it 'parses out a file to KeyMap object' do
        expect(described_class.load_file(cached_short_path)).to eql({"keycode1"=>"Escape", ["shift", "keycode1"]=>"Escape", ["altgr", "keycode1"]=>"Escape",
          ["shift", "altgr", "keycode1"]=>"Escape", ["control", "keycode1"]=>"Escape", ["shift", "control", "keycode1"]=>"Escape",
          ["altgr", "control", "keycode1"]=>"Escape", ["shift", "altgr", "control", "keycode1"]=>"Escape", ["alt", "keycode1"]=>"Meta_Escape",["shift", "alt", "keycode1"]=>"Meta_Escape",
          ["altgr", "alt", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "alt", "keycode1"]=>"Meta_Escape", ["control", "alt", "keycode1"]=>"Meta_Escape",
          ["shift", "control", "alt", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "control", "alt", "keycode1"]=>"Meta_Escape",
          ["shiftl", "keycode1"]=>"Escape", ["shift", "shiftl", "keycode1"]=>"Escape", ["altgr", "shiftl", "keycode1"]=>"Escape",
          ["shift", "altgr", "shiftl", "keycode1"]=>"Escape", ["control", "shiftl", "keycode1"]=>"Escape", ["shift", "control", "shiftl", "keycode1"]=>"Escape",
          ["altgr", "control", "shiftl", "keycode1"]=>"Escape", ["shift", "altgr", "control", "shiftl", "keycode1"]=>"Escape", ["alt", "shiftl", "keycode1"]=>"Meta_Escape",
          ["shift", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "alt", "shiftl", "keycode1"]=>"Meta_Escape",
          ["control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["shift", "control", "alt", "shiftl", "keycode1"]=>"Meta_Escape",
          ["altgr", "control", "alt", "shiftl", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "control", "alt", "shiftl", "keycode1"]=>"Meta_Escape",
          ["shiftr", "keycode1"]=>"Escape", ["shift", "shiftr", "keycode1"]=>"Escape", ["altgr", "shiftr", "keycode1"]=>"Escape",
          ["shift", "altgr", "shiftr", "keycode1"]=>"Escape", ["control", "shiftr", "keycode1"]=>"Escape", ["shift", "control", "shiftr", "keycode1"]=>"Escape",
          ["altgr", "control", "shiftr", "keycode1"]=>"Escape", ["shift", "altgr", "control", "shiftr", "keycode1"]=>"Escape", ["alt", "shiftr", "keycode1"]=>"Meta_Escape",
          ["shift", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "alt", "shiftr", "keycode1"]=>"Meta_Escape",
          ["control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "control", "alt", "shiftr", "keycode1"]=>"Meta_Escape",
          ["altgr", "control", "alt", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "control", "alt", "shiftr", "keycode1"]=>"Meta_Escape",
          ["shiftl", "shiftr", "keycode1"]=>"Escape", ["shift", "shiftl", "shiftr", "keycode1"]=>"Escape", ["altgr", "shiftl", "shiftr", "keycode1"]=>"Escape",
          ["shift", "altgr", "shiftl", "shiftr", "keycode1"]=>"Escape", ["control", "shiftl", "shiftr", "keycode1"]=>"Escape", ["shift", "control","shiftl", "shiftr", "keycode1"]=>"Escape",
          ["altgr", "control", "shiftl", "shiftr", "keycode1"]=>"Escape", ["shift", "altgr", "control", "shiftl", "shiftr", "keycode1"]=>"Escape",
          ["alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape",
          ["altgr", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape",
          ["control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape",
          ["altgr", "control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "keycode1"]=>"Meta_Escape",
          ["ctrll", "keycode1"]=>"Escape", ["shift", "ctrll", "keycode1"]=>"Escape", ["altgr", "ctrll", "keycode1"]=>"Escape",
          ["shift", "altgr", "ctrll", "keycode1"]=>"Escape", ["control", "ctrll", "keycode1"]=>"Escape", ["shift", "control", "ctrll", "keycode1"]=>"Escape",
          ["altgr", "control", "ctrll", "keycode1"]=>"Escape", ["shift", "altgr", "control", "ctrll", "keycode1"]=>"Escape", ["alt", "ctrll", "keycode1"]=>"Meta_Escape",
          ["shift", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "alt", "ctrll", "keycode1"]=>"Meta_Escape",
          ["control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "control", "alt", "ctrll", "keycode1"]=>"Meta_Escape",
          ["altgr", "control", "alt", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "control", "alt", "ctrll", "keycode1"]=>"Meta_Escape",
          ["shiftl", "ctrll", "keycode1"]=>"Escape", ["shift", "shiftl", "ctrll", "keycode1"]=>"Escape", ["altgr", "shiftl", "ctrll", "keycode1"]=>"Escape",
          ["shift", "altgr", "shiftl", "ctrll", "keycode1"]=>"Escape", ["control", "shiftl", "ctrll", "keycode1"]=>"Escape", ["shift", "control", "shiftl", "ctrll", "keycode1"]=>"Escape",
          ["altgr", "control", "shiftl", "ctrll", "keycode1"]=>"Escape", ["shift", "altgr", "control", "shiftl", "ctrll", "keycode1"]=>"Escape",
          ["alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape",
          ["altgr", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape",
          ["control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape",
          ["altgr", "control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "control", "alt", "shiftl", "ctrll", "keycode1"]=>"Meta_Escape",
          ["shiftr", "ctrll", "keycode1"]=>"Escape", ["shift", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "shiftr", "ctrll", "keycode1"]=>"Escape",
          ["shift", "altgr", "shiftr", "ctrll", "keycode1"]=>"Escape", ["control", "shiftr", "ctrll", "keycode1"]=>"Escape", ["shift", "control", "shiftr", "ctrll", "keycode1"]=>"Escape",
          ["altgr", "control", "shiftr", "ctrll", "keycode1"]=>"Escape", ["shift", "altgr", "control", "shiftr", "ctrll", "keycode1"]=>"Escape",
          ["alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape",
          ["altgr", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape",
          ["control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape",
          ["altgr", "control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["shift", "altgr", "control", "alt", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape",
          ["shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["shift", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape",
          ["shift", "altgr", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape",
          ["shift", "control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["altgr", "control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape",
          ["shift", "altgr", "control", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Escape", ["alt", "shiftl", "shiftr","ctrll", "keycode1"]=>"Meta_Escape",
          ["shift", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape",
          ["shift", "altgr", "alt", "shiftl", "shiftr", "ctrll","keycode1"]=>"Meta_Escape", ["control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape",
          ["shift", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", ["altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape",
          ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode1"]=>"Meta_Escape", "keycode2"=>"U+0031", ["shift", "keycode2"]=>"U+0021", ["altgr", "keycode2"]=>"U+0031",
          ["shift", "altgr", "keycode2"]=>"U+0021", ["control", "keycode2"]=>"VoidSymbol", ["shift", "control", "keycode2"]=>"VoidSymbol",
          ["altgr", "control", "keycode2"]=>"VoidSymbol", ["shift", "altgr", "control", "keycode2"]=>"VoidSymbol", ["alt", "keycode2"]=>"Meta_one",
          ["shift", "alt", "keycode2"]=>"Meta_exclam", ["altgr", "alt", "keycode2"]=>"Meta_one", ["shift", "altgr", "alt", "keycode2"]=>"Meta_exclam",
          ["control", "alt", "keycode2"]=>"VoidSymbol", ["shift", "control", "alt", "keycode2"]=>"VoidSymbol", ["altgr", "control", "alt", "keycode2"]=>"VoidSymbol",
          ["shift", "altgr", "control", "alt", "keycode2"]=>"VoidSymbol", ["shiftl", "keycode2"]=>"U+0031", ["shift", "shiftl", "keycode2"]=>"U+0021",
          ["altgr", "shiftl", "keycode2"]=>"U+0031", ["shift", "altgr", "shiftl", "keycode2"]=>"U+0021", ["control", "shiftl", "keycode2"]=>"VoidSymbol",
          ["shift", "control", "shiftl", "keycode2"]=>"VoidSymbol", ["altgr", "control", "shiftl", "keycode2"]=>"VoidSymbol", ["shift", "altgr","control", "shiftl", "keycode2"]=>"VoidSymbol",
          ["alt", "shiftl", "keycode2"]=>"Meta_one", ["shift", "alt", "shiftl", "keycode2"]=>"Meta_exclam", ["altgr", "alt", "shiftl", "keycode2"]=>"Meta_one",
          ["shift", "altgr", "alt", "shiftl", "keycode2"]=>"Meta_exclam", ["control", "alt", "shiftl", "keycode2"]=>"VoidSymbol", ["shift", "control", "alt", "shiftl", "keycode2"]=>"VoidSymbol",
          ["altgr", "control", "alt", "shiftl", "keycode2"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "shiftl", "keycode2"]=>"VoidSymbol",
          ["shiftr", "keycode2"]=>"U+0031", ["shift", "shiftr", "keycode2"]=>"U+0021", ["altgr", "shiftr", "keycode2"]=>"U+0031",
          ["shift", "altgr", "shiftr", "keycode2"]=>"U+0021", ["control", "shiftr", "keycode2"]=>"VoidSymbol", ["shift", "control", "shiftr", "keycode2"]=>"VoidSymbol",
          ["altgr", "control", "shiftr", "keycode2"]=>"VoidSymbol", ["shift", "altgr", "control", "shiftr", "keycode2"]=>"VoidSymbol",
          ["alt", "shiftr", "keycode2"]=>"Meta_one", ["shift", "alt", "shiftr", "keycode2"]=>"Meta_exclam", ["altgr", "alt", "shiftr", "keycode2"]=>"Meta_one",
          ["shift", "altgr", "alt", "shiftr", "keycode2"]=>"Meta_exclam", ["control", "alt", "shiftr", "keycode2"]=>"VoidSymbol", ["shift", "control", "alt", "shiftr", "keycode2"]=>"VoidSymbol",
          ["altgr", "control", "alt", "shiftr", "keycode2"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "shiftr", "keycode2"]=>"VoidSymbol",
          ["shiftl", "shiftr", "keycode2"]=>"U+0031", ["shift", "shiftl", "shiftr", "keycode2"]=>"U+0021", ["altgr", "shiftl", "shiftr", "keycode2"]=>"U+0031",
          ["shift","altgr", "shiftl", "shiftr", "keycode2"]=>"U+0021", ["control", "shiftl", "shiftr", "keycode2"]=>"VoidSymbol", ["shift", "control", "shiftl", "shiftr", "keycode2"]=>"VoidSymbol",
          ["altgr", "control", "shiftl", "shiftr", "keycode2"]=>"VoidSymbol", ["shift", "altgr", "control", "shiftl", "shiftr", "keycode2"]=>"VoidSymbol",
          ["alt", "shiftl", "shiftr", "keycode2"]=>"Meta_one", ["shift", "alt", "shiftl", "shiftr", "keycode2"]=>"Meta_exclam",
          ["altgr", "alt", "shiftl", "shiftr", "keycode2"]=>"Meta_one", ["shift", "altgr", "alt", "shiftl", "shiftr", "keycode2"]=>"Meta_exclam",
          ["control", "alt", "shiftl", "shiftr", "keycode2"]=>"VoidSymbol", ["shift", "control", "alt", "shiftl", "shiftr", "keycode2"]=>"VoidSymbol",
          ["altgr", "control", "alt", "shiftl", "shiftr", "keycode2"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "keycode2"]=>"VoidSymbol",
          ["ctrll", "keycode2"]=>"U+0031", ["shift", "ctrll", "keycode2"]=>"U+0021", ["altgr", "ctrll", "keycode2"]=>"U+0031",
          ["shift", "altgr", "ctrll", "keycode2"]=>"U+0021", ["control", "ctrll", "keycode2"]=>"VoidSymbol", ["shift", "control", "ctrll", "keycode2"]=>"VoidSymbol",
          ["altgr", "control", "ctrll", "keycode2"]=>"VoidSymbol", ["shift", "altgr", "control", "ctrll", "keycode2"]=>"VoidSymbol",
          ["alt", "ctrll", "keycode2"]=>"Meta_one", ["shift", "alt", "ctrll", "keycode2"]=>"Meta_exclam", ["altgr", "alt", "ctrll", "keycode2"]=>"Meta_one",
          ["shift", "altgr","alt", "ctrll", "keycode2"]=>"Meta_exclam", ["control", "alt", "ctrll", "keycode2"]=>"VoidSymbol", ["shift", "control","alt", "ctrll", "keycode2"]=>"VoidSymbol",
          ["altgr", "control", "alt", "ctrll", "keycode2"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "ctrll", "keycode2"]=>"VoidSymbol",
          ["shiftl", "ctrll", "keycode2"]=>"U+0031", ["shift", "shiftl", "ctrll", "keycode2"]=>"U+0021", ["altgr", "shiftl", "ctrll", "keycode2"]=>"U+0031",
          ["shift", "altgr", "shiftl", "ctrll", "keycode2"]=>"U+0021", ["control", "shiftl", "ctrll", "keycode2"]=>"VoidSymbol", ["shift", "control", "shiftl", "ctrll", "keycode2"]=>"VoidSymbol",
          ["altgr", "control", "shiftl", "ctrll", "keycode2"]=>"VoidSymbol", ["shift", "altgr", "control", "shiftl", "ctrll", "keycode2"]=>"VoidSymbol",
          ["alt", "shiftl", "ctrll", "keycode2"]=>"Meta_one", ["shift", "alt", "shiftl", "ctrll", "keycode2"]=>"Meta_exclam",
          ["altgr", "alt", "shiftl", "ctrll", "keycode2"]=>"Meta_one", ["shift", "altgr", "alt", "shiftl", "ctrll", "keycode2"]=>"Meta_exclam",
          ["control", "alt", "shiftl", "ctrll", "keycode2"]=>"VoidSymbol", ["shift", "control", "alt", "shiftl", "ctrll", "keycode2"]=>"VoidSymbol",
          ["altgr", "control", "alt", "shiftl", "ctrll", "keycode2"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "shiftl", "ctrll", "keycode2"]=>"VoidSymbol",
          ["shiftr", "ctrll", "keycode2"]=>"U+0031", ["shift", "shiftr", "ctrll", "keycode2"]=>"U+0021", ["altgr", "shiftr", "ctrll", "keycode2"]=>"U+0031",
          ["shift", "altgr", "shiftr", "ctrll", "keycode2"]=>"U+0021", ["control", "shiftr", "ctrll", "keycode2"]=>"VoidSymbol", ["shift", "control", "shiftr", "ctrll", "keycode2"]=>"VoidSymbol",
          ["altgr", "control", "shiftr", "ctrll", "keycode2"]=>"VoidSymbol", ["shift", "altgr", "control", "shiftr", "ctrll", "keycode2"]=>"VoidSymbol",
          ["alt", "shiftr", "ctrll", "keycode2"]=>"Meta_one", ["shift", "alt", "shiftr", "ctrll", "keycode2"]=>"Meta_exclam",
          ["altgr", "alt", "shiftr", "ctrll", "keycode2"]=>"Meta_one", ["shift", "altgr", "alt", "shiftr", "ctrll", "keycode2"]=>"Meta_exclam",
          ["control", "alt", "shiftr", "ctrll", "keycode2"]=>"VoidSymbol", ["shift", "control", "alt", "shiftr", "ctrll","keycode2"]=>"VoidSymbol",
          ["altgr", "control", "alt", "shiftr", "ctrll", "keycode2"]=>"VoidSymbol", ["shift", "altgr","control", "alt", "shiftr", "ctrll", "keycode2"]=>"VoidSymbol",
          ["shiftl", "shiftr", "ctrll", "keycode2"]=>"U+0031", ["shift", "shiftl", "shiftr", "ctrll", "keycode2"]=>"U+0021", ["altgr", "shiftl", "shiftr", "ctrll", "keycode2"]=>"U+0031",
          ["shift", "altgr", "shiftl", "shiftr", "ctrll", "keycode2"]=>"U+0021", ["control", "shiftl", "shiftr", "ctrll", "keycode2"]=>"VoidSymbol",
          ["shift", "control", "shiftl", "shiftr", "ctrll", "keycode2"]=>"VoidSymbol", ["altgr", "control", "shiftl", "shiftr", "ctrll", "keycode2"]=>"VoidSymbol",
          ["shift", "altgr", "control", "shiftl", "shiftr", "ctrll", "keycode2"]=>"VoidSymbol", ["alt", "shiftl", "shiftr", "ctrll", "keycode2"]=>"Meta_one", ["shift", "alt", "shiftl", "shiftr", "ctrll", "keycode2"]=>"Meta_exclam",
          ["altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode2"]=>"Meta_one", ["shift", "altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode2"]=>"Meta_exclam",
          ["control", "alt", "shiftl", "shiftr", "ctrll", "keycode2"]=>"VoidSymbol", ["shift", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode2"]=>"VoidSymbol",
          ["altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode2"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "shiftl","shiftr", "ctrll", "keycode2"]=>"VoidSymbol", "keycode10"=>"U+0039",
          ["shift", "keycode10"]=>"U+0028", ["altgr", "keycode10"]=>"U+0039", ["shift", "altgr", "keycode10"]=>"U+0039",
          ["control", "keycode10"]=>"VoidSymbol", ["shift", "control", "keycode10"]=>"VoidSymbol", ["altgr", "control", "keycode10"]=>"VoidSymbol",
          ["shift", "altgr", "control", "keycode10"]=>"VoidSymbol", ["alt", "keycode10"]=>"Meta_nine", ["shift", "alt", "keycode10"]=>"Meta_parenleft",
          ["altgr", "alt", "keycode10"]=>"Meta_nine", ["shift", "altgr", "alt", "keycode10"]=>"Meta_nine", ["control", "alt", "keycode10"]=>"VoidSymbol",
          ["shift", "control", "alt", "keycode10"]=>"VoidSymbol", ["altgr", "control", "alt", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "keycode10"]=>"VoidSymbol",
          ["shiftl", "keycode10"]=>"U+0039", ["shift", "shiftl", "keycode10"]=>"U+0028", ["altgr", "shiftl", "keycode10"]=>"U+0039",
          ["shift", "altgr", "shiftl", "keycode10"]=>"U+0039", ["control", "shiftl", "keycode10"]=>"VoidSymbol", ["shift", "control", "shiftl", "keycode10"]=>"VoidSymbol",
          ["altgr", "control", "shiftl", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "shiftl", "keycode10"]=>"VoidSymbol",
          ["alt", "shiftl", "keycode10"]=>"Meta_nine", ["shift", "alt", "shiftl", "keycode10"]=>"Meta_parenleft", ["altgr", "alt", "shiftl", "keycode10"]=>"Meta_nine",
          ["shift", "altgr", "alt", "shiftl", "keycode10"]=>"Meta_nine", ["control", "alt", "shiftl", "keycode10"]=>"VoidSymbol", ["shift", "control", "alt", "shiftl", "keycode10"]=>"VoidSymbol",
          ["altgr", "control", "alt", "shiftl", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "shiftl", "keycode10"]=>"VoidSymbol",
          ["shiftr", "keycode10"]=>"U+0039", ["shift", "shiftr", "keycode10"]=>"U+0028", ["altgr", "shiftr", "keycode10"]=>"U+0039",
          ["shift", "altgr", "shiftr", "keycode10"]=>"U+0039", ["control", "shiftr", "keycode10"]=>"VoidSymbol", ["shift", "control", "shiftr", "keycode10"]=>"VoidSymbol",
          ["altgr", "control", "shiftr", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "shiftr", "keycode10"]=>"VoidSymbol",
          ["alt", "shiftr", "keycode10"]=>"Meta_nine", ["shift", "alt", "shiftr", "keycode10"]=>"Meta_parenleft", ["altgr", "alt", "shiftr", "keycode10"]=>"Meta_nine",
          ["shift", "altgr", "alt", "shiftr", "keycode10"]=>"Meta_nine", ["control", "alt", "shiftr", "keycode10"]=>"VoidSymbol", ["shift", "control", "alt", "shiftr", "keycode10"]=>"VoidSymbol",
          ["altgr", "control", "alt", "shiftr", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "shiftr", "keycode10"]=>"VoidSymbol",
          ["shiftl", "shiftr", "keycode10"]=>"U+0039", ["shift", "shiftl","shiftr", "keycode10"]=>"U+0028", ["altgr", "shiftl", "shiftr", "keycode10"]=>"U+0039",
          ["shift", "altgr", "shiftl", "shiftr", "keycode10"]=>"U+0039", ["control", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", ["shift", "control", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol",
          ["altgr", "control", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol",
          ["alt", "shiftl", "shiftr", "keycode10"]=>"Meta_nine", ["shift", "alt", "shiftl", "shiftr", "keycode10"]=>"Meta_parenleft",
          ["altgr", "alt", "shiftl", "shiftr", "keycode10"]=>"Meta_nine", ["shift", "altgr", "alt", "shiftl", "shiftr", "keycode10"]=>"Meta_nine",
          ["control", "alt", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", ["shift", "control", "alt", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol",
          ["altgr", "control", "alt", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "keycode10"]=>"VoidSymbol",
          ["ctrll", "keycode10"]=>"U+0039", ["shift", "ctrll", "keycode10"]=>"U+0028", ["altgr", "ctrll", "keycode10"]=>"U+0039",
          ["shift", "altgr", "ctrll", "keycode10"]=>"U+0039", ["control", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "control", "ctrll", "keycode10"]=>"VoidSymbol",
          ["altgr", "control", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "ctrll", "keycode10"]=>"VoidSymbol",
          ["alt", "ctrll", "keycode10"]=>"Meta_nine",["shift", "alt", "ctrll", "keycode10"]=>"Meta_parenleft", ["altgr", "alt", "ctrll", "keycode10"]=>"Meta_nine",["shift", "altgr", "alt", "ctrll", "keycode10"]=>"Meta_nine",
          ["control", "alt", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "control", "alt", "ctrll", "keycode10"]=>"VoidSymbol",
          ["altgr", "control", "alt", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "ctrll", "keycode10"]=>"VoidSymbol",
          ["shiftl", "ctrll", "keycode10"]=>"U+0039", ["shift", "shiftl", "ctrll", "keycode10"]=>"U+0028", ["altgr", "shiftl", "ctrll", "keycode10"]=>"U+0039",
          ["shift", "altgr", "shiftl", "ctrll", "keycode10"]=>"U+0039", ["control", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "control", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol",
          ["altgr", "control", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol",["shift", "altgr", "control", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol",
          ["alt", "shiftl", "ctrll", "keycode10"]=>"Meta_nine", ["shift", "alt", "shiftl", "ctrll", "keycode10"]=>"Meta_parenleft",
          ["altgr", "alt", "shiftl", "ctrll", "keycode10"]=>"Meta_nine", ["shift", "altgr", "alt", "shiftl", "ctrll", "keycode10"]=>"Meta_nine",
          ["control", "alt", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "control", "alt", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol",
          ["altgr", "control", "alt", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "shiftl", "ctrll", "keycode10"]=>"VoidSymbol",
          ["shiftr", "ctrll", "keycode10"]=>"U+0039", ["shift", "shiftr", "ctrll", "keycode10"]=>"U+0028", ["altgr", "shiftr", "ctrll", "keycode10"]=>"U+0039",
          ["shift", "altgr", "shiftr", "ctrll", "keycode10"]=>"U+0039", ["control", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "control", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol",
          ["altgr", "control", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol",
          ["alt", "shiftr", "ctrll", "keycode10"]=>"Meta_nine", ["shift", "alt", "shiftr", "ctrll", "keycode10"]=>"Meta_parenleft",
          ["altgr", "alt", "shiftr", "ctrll", "keycode10"]=>"Meta_nine", ["shift", "altgr", "alt", "shiftr", "ctrll", "keycode10"]=>"Meta_nine",
          ["control", "alt", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "control", "alt", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol",
          ["altgr", "control", "alt", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["shift", "altgr", "control", "alt", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol",
          ["shiftl", "shiftr", "ctrll", "keycode10"]=>"U+0039", ["shift", "shiftl", "shiftr", "ctrll", "keycode10"]=>"U+0028", ["altgr", "shiftl", "shiftr", "ctrll", "keycode10"]=>"U+0039",
          ["shift", "altgr", "shiftl", "shiftr", "ctrll", "keycode10"]=>"U+0039", ["control", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol",
          ["shift", "control", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["altgr", "control", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol",
          ["shift", "altgr", "control", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"Meta_nine",
          ["shift", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"Meta_parenleft", ["altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"Meta_nine",
          ["shift", "altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"Meta_nine", ["control", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol",
          ["shift", "control", "alt","shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", ["altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol",
          ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode10"]=>"VoidSymbol", "keycode121"=>"KP_Period", ["shift", "keycode121"]=>"KP_Period", ["altgr", "keycode121"]=>"KP_Period",
          ["shift", "altgr", "keycode121"]=>"KP_Period", ["control", "keycode121"]=>"KP_Period", ["shift", "control", "keycode121"]=>"KP_Period",
          ["altgr", "control", "keycode121"]=>"KP_Period", ["shift", "altgr", "control", "keycode121"]=>"KP_Period", ["alt", "keycode121"]=>"KP_Period",
          ["shift", "alt", "keycode121"]=>"KP_Period", ["altgr", "alt", "keycode121"]=>"KP_Period", ["shift", "altgr", "alt", "keycode121"]=>"KP_Period",
          ["control", "alt", "keycode121"]=>"KP_Period", ["shift", "control", "alt", "keycode121"]=>"KP_Period", ["altgr", "control", "alt", "keycode121"]=>"KP_Period",
          ["shift", "altgr", "control", "alt", "keycode121"]=>"KP_Period", ["shiftl", "keycode121"]=>"KP_Period", ["shift", "shiftl", "keycode121"]=>"KP_Period",
          ["altgr", "shiftl", "keycode121"]=>"KP_Period", ["shift", "altgr", "shiftl", "keycode121"]=>"KP_Period", ["control", "shiftl","keycode121"]=>"KP_Period",
          ["shift", "control", "shiftl", "keycode121"]=>"KP_Period", ["altgr", "control", "shiftl", "keycode121"]=>"KP_Period", ["shift", "altgr", "control", "shiftl", "keycode121"]=>"KP_Period",
          ["alt", "shiftl", "keycode121"]=>"KP_Period", ["shift", "alt", "shiftl", "keycode121"]=>"KP_Period", ["altgr", "alt", "shiftl", "keycode121"]=>"KP_Period",
          ["shift", "altgr", "alt", "shiftl", "keycode121"]=>"KP_Period", ["control", "alt", "shiftl", "keycode121"]=>"KP_Period", ["shift", "control", "alt", "shiftl", "keycode121"]=>"KP_Period",
          ["altgr", "control", "alt", "shiftl", "keycode121"]=>"KP_Period", ["shift", "altgr", "control", "alt", "shiftl", "keycode121"]=>"KP_Period",
          ["shiftr", "keycode121"]=>"KP_Period", ["shift", "shiftr", "keycode121"]=>"KP_Period", ["altgr", "shiftr", "keycode121"]=>"KP_Period",
          ["shift", "altgr", "shiftr", "keycode121"]=>"KP_Period", ["control", "shiftr", "keycode121"]=>"KP_Period", ["shift", "control", "shiftr", "keycode121"]=>"KP_Period",
          ["altgr", "control", "shiftr", "keycode121"]=>"KP_Period", ["shift", "altgr", "control", "shiftr", "keycode121"]=>"KP_Period",
          ["alt", "shiftr", "keycode121"]=>"KP_Period", ["shift", "alt", "shiftr", "keycode121"]=>"KP_Period", ["altgr", "alt", "shiftr", "keycode121"]=>"KP_Period",
          ["shift", "altgr", "alt", "shiftr", "keycode121"]=>"KP_Period", ["control", "alt", "shiftr", "keycode121"]=>"KP_Period", ["shift", "control", "alt", "shiftr", "keycode121"]=>"KP_Period",
          ["altgr", "control", "alt", "shiftr", "keycode121"]=>"KP_Period", ["shift", "altgr", "control", "alt", "shiftr", "keycode121"]=>"KP_Period",
          ["shiftl", "shiftr", "keycode121"]=>"KP_Period", ["shift", "shiftl", "shiftr", "keycode121"]=>"KP_Period", ["altgr", "shiftl", "shiftr", "keycode121"]=>"KP_Period",
          ["shift", "altgr", "shiftl", "shiftr", "keycode121"]=>"KP_Period", ["control", "shiftl", "shiftr", "keycode121"]=>"KP_Period", ["shift", "control", "shiftl", "shiftr", "keycode121"]=>"KP_Period",
          ["altgr", "control", "shiftl", "shiftr", "keycode121"]=>"KP_Period",["shift", "altgr", "control", "shiftl", "shiftr", "keycode121"]=>"KP_Period",
          ["alt", "shiftl", "shiftr", "keycode121"]=>"KP_Period", ["shift", "alt", "shiftl", "shiftr", "keycode121"]=>"KP_Period",
          ["altgr", "alt", "shiftl", "shiftr", "keycode121"]=>"KP_Period", ["shift", "altgr", "alt", "shiftl", "shiftr", "keycode121"]=>"KP_Period",
          ["control", "alt", "shiftl", "shiftr", "keycode121"]=>"KP_Period", ["shift", "control", "alt", "shiftl", "shiftr", "keycode121"]=>"KP_Period",
          ["altgr", "control", "alt", "shiftl", "shiftr", "keycode121"]=>"KP_Period", ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "keycode121"]=>"KP_Period",
          ["ctrll", "keycode121"]=>"KP_Period", ["shift", "ctrll", "keycode121"]=>"KP_Period", ["altgr", "ctrll", "keycode121"]=>"KP_Period",
          ["shift", "altgr", "ctrll", "keycode121"]=>"KP_Period", ["control", "ctrll", "keycode121"]=>"KP_Period", ["shift", "control", "ctrll", "keycode121"]=>"KP_Period",
          ["altgr", "control", "ctrll", "keycode121"]=>"KP_Period", ["shift", "altgr", "control", "ctrll", "keycode121"]=>"KP_Period",
          ["alt", "ctrll", "keycode121"]=>"KP_Period", ["shift", "alt", "ctrll", "keycode121"]=>"KP_Period", ["altgr", "alt", "ctrll", "keycode121"]=>"KP_Period",
          ["shift", "altgr", "alt", "ctrll", "keycode121"]=>"KP_Period", ["control", "alt", "ctrll", "keycode121"]=>"KP_Period", ["shift", "control", "alt", "ctrll", "keycode121"]=>"KP_Period",
          ["altgr", "control", "alt", "ctrll", "keycode121"]=>"KP_Period", ["shift", "altgr", "control", "alt", "ctrll", "keycode121"]=>"KP_Period",
          ["shiftl", "ctrll", "keycode121"]=>"KP_Period", ["shift", "shiftl", "ctrll", "keycode121"]=>"KP_Period", ["altgr", "shiftl", "ctrll", "keycode121"]=>"KP_Period",
          ["shift", "altgr", "shiftl", "ctrll", "keycode121"]=>"KP_Period", ["control", "shiftl", "ctrll", "keycode121"]=>"KP_Period", ["shift", "control", "shiftl", "ctrll", "keycode121"]=>"KP_Period",
          ["altgr", "control", "shiftl", "ctrll", "keycode121"]=>"KP_Period", ["shift", "altgr", "control", "shiftl", "ctrll", "keycode121"]=>"KP_Period",
          ["alt", "shiftl", "ctrll", "keycode121"]=>"KP_Period", ["shift", "alt", "shiftl", "ctrll", "keycode121"]=>"KP_Period",
          ["altgr", "alt", "shiftl", "ctrll", "keycode121"]=>"KP_Period", ["shift", "altgr", "alt", "shiftl", "ctrll", "keycode121"]=>"KP_Period",
          ["control", "alt", "shiftl", "ctrll", "keycode121"]=>"KP_Period", ["shift", "control", "alt", "shiftl", "ctrll", "keycode121"]=>"KP_Period",
          ["altgr", "control", "alt", "shiftl", "ctrll", "keycode121"]=>"KP_Period", ["shift","altgr", "control", "alt", "shiftl", "ctrll", "keycode121"]=>"KP_Period",
          ["shiftr", "ctrll", "keycode121"]=>"KP_Period", ["shift", "shiftr", "ctrll", "keycode121"]=>"KP_Period", ["altgr", "shiftr", "ctrll", "keycode121"]=>"KP_Period",
          ["shift", "altgr", "shiftr", "ctrll", "keycode121"]=>"KP_Period", ["control", "shiftr", "ctrll", "keycode121"]=>"KP_Period", ["shift", "control", "shiftr", "ctrll", "keycode121"]=>"KP_Period",
          ["altgr", "control", "shiftr", "ctrll", "keycode121"]=>"KP_Period", ["shift", "altgr", "control", "shiftr", "ctrll", "keycode121"]=>"KP_Period",
          ["alt", "shiftr", "ctrll", "keycode121"]=>"KP_Period", ["shift", "alt", "shiftr", "ctrll", "keycode121"]=>"KP_Period",
          ["altgr", "alt", "shiftr","ctrll", "keycode121"]=>"KP_Period", ["shift", "altgr", "alt", "shiftr", "ctrll", "keycode121"]=>"KP_Period",
          ["control", "alt", "shiftr", "ctrll", "keycode121"]=>"KP_Period", ["shift", "control", "alt", "shiftr", "ctrll", "keycode121"]=>"KP_Period",
          ["altgr", "control", "alt", "shiftr", "ctrll", "keycode121"]=>"KP_Period", ["shift", "altgr", "control", "alt", "shiftr", "ctrll", "keycode121"]=>"KP_Period",
          ["shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period", ["shift", "shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period",
          ["altgr", "shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period", ["shift", "altgr", "shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period",
          ["control", "shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period", ["shift", "control", "shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period",
          ["altgr", "control", "shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period", ["shift", "altgr", "control", "shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period",
          ["alt", "shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period", ["shift", "alt", "shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period",
          ["altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period", ["shift", "altgr", "alt", "shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period",
          ["control", "alt", "shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period", ["shift", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period",
          ["altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period", ["shift", "altgr", "control", "alt", "shiftl", "shiftr", "ctrll", "keycode121"]=>"KP_Period"})
      end
    end
  end
  
  context 'instance_methods after loaded file' do
    
    context 'cached' do
      subject { described_class.load_file(cached_short_path) }
      
      describe '#left_side' do
        it 'returns the keycode for that key combination' do
          #puts subject.inspect
          expect(subject.left_side('Escape')).to eql(["keycode1", ["shift", "keycode1"], ["altgr", "keycode1"], 
            ["shift", "altgr", "keycode1"], ["control","keycode1"], ["shift", "control", "keycode1"], ["altgr", "control", "keycode1"], 
            ["shift", "altgr", "control", "keycode1"], ["shiftl", "keycode1"], ["shift", "shiftl", "keycode1"], 
            ["altgr", "shiftl", "keycode1"], ["shift", "altgr", "shiftl", "keycode1"], ["control", "shiftl", "keycode1"], 
            ["shift", "control", "shiftl", "keycode1"], ["altgr", "control", "shiftl", "keycode1"], 
            ["shift", "altgr", "control", "shiftl", "keycode1"], ["shiftr", "keycode1"], ["shift", "shiftr", "keycode1"], 
            ["altgr", "shiftr", "keycode1"], ["shift", "altgr", "shiftr", "keycode1"], ["control", "shiftr", "keycode1"], 
            ["shift", "control", "shiftr", "keycode1"], ["altgr", "control", "shiftr", "keycode1"], 
            ["shift", "altgr", "control", "shiftr", "keycode1"], ["shiftl", "shiftr", "keycode1"], 
            ["shift", "shiftl", "shiftr", "keycode1"], ["altgr", "shiftl", "shiftr", "keycode1"], 
            ["shift", "altgr", "shiftl", "shiftr", "keycode1"], ["control", "shiftl", "shiftr", "keycode1"], 
            ["shift", "control", "shiftl", "shiftr", "keycode1"], ["altgr", "control", "shiftl", "shiftr", "keycode1"], 
            ["shift", "altgr", "control", "shiftl", "shiftr", "keycode1"], ["ctrll", "keycode1"], ["shift", "ctrll", "keycode1"], 
            ["altgr", "ctrll", "keycode1"], ["shift", "altgr", "ctrll", "keycode1"], ["control", "ctrll", "keycode1"], 
            ["shift", "control", "ctrll","keycode1"], ["altgr", "control", "ctrll", "keycode1"], 
            ["shift", "altgr", "control", "ctrll", "keycode1"], ["shiftl", "ctrll", "keycode1"], 
            ["shift", "shiftl", "ctrll", "keycode1"], ["altgr", "shiftl", "ctrll", "keycode1"], 
            ["shift", "altgr", "shiftl", "ctrll", "keycode1"], ["control", "shiftl", "ctrll", "keycode1"], 
            ["shift", "control", "shiftl", "ctrll","keycode1"], ["altgr", "control", "shiftl", "ctrll", "keycode1"], 
            ["shift", "altgr", "control", "shiftl", "ctrll", "keycode1"], ["shiftr", "ctrll", "keycode1"], 
            ["shift", "shiftr", "ctrll", "keycode1"], ["altgr", "shiftr", "ctrll", "keycode1"], 
            ["shift", "altgr", "shiftr", "ctrll", "keycode1"], ["control", "shiftr", "ctrll", "keycode1"], 
            ["shift", "control", "shiftr", "ctrll", "keycode1"], ["altgr", "control", "shiftr", "ctrll", "keycode1"], 
            ["shift", "altgr", "control", "shiftr", "ctrll", "keycode1"], ["shiftl", "shiftr", "ctrll", "keycode1"], 
            ["shift", "shiftl", "shiftr", "ctrll", "keycode1"], ["altgr", "shiftl", "shiftr", "ctrll", "keycode1"], 
            ["shift", "altgr", "shiftl", "shiftr", "ctrll", "keycode1"], ["control", "shiftl", "shiftr", "ctrll", "keycode1"], 
            ["shift", "control", "shiftl", "shiftr", "ctrll", "keycode1"], 
            ["altgr", "control", "shiftl", "shiftr", "ctrll", "keycode1"], 
            ["shift", "altgr", "control", "shiftl", "shiftr", "ctrll", "keycode1"]])
        end
      end
      
      describe '#right_side' do
        it 'returns the the different combinations of keys that could have produced this keysym' do
          expect(subject.right_side('keycode121')).to eql('KP_Period')
        end
      end
    end
    
    context 'dump_keys' do
      subject { described_class.load_file(dump_keys_short_path) }
      
      describe '#left_side' do
        it 'returns the keycode for that key combination' do
          expect(subject.left_side('Escape')).to eql('keycode1')
        end
      end
      describe '#right_side' do
        it 'returns the the different combinations of keys that could have produced this keysym' do
          expect(subject.right_side('keycode121')).to eql('KP_Period')
        end
      end
    end
    
  end
end
