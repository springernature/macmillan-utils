require 'spec_helper'

describe Macmillan::Utils::Helper::StringConversionHelper do
  include Macmillan::Utils::Helper::StringConversionHelper

  describe '#snakecase_string' do
    it 'downcases' do
      expect(snakecase_string('URI')).to eq('uri')
    end

    it 'converts spaces' do
      expect(snakecase_string('MyStuff  HisStuff')).to eq('my_stuff_his_stuff')
    end

    it 'does not alter path dividers' do
      expect(snakecase_string('/my_module/my_class/')).to eq('/my_module/my_class/')
    end
  end

  describe '#upper_camelcase_string' do
    let(:spacey_string)      {'I feel spaced out'}
    let(:underscorey_string) {'i_feel_under_scored'}

    it 'converts a string containing spaces to upper camelcase' do
      expect(upper_camelcase_string(spacey_string)).to eq('IFeelSpacedOut')
    end

    it 'converts a string containing underscores to upper camelcase' do
      expect(upper_camelcase_string(underscorey_string)).to eq('IFeelUnderScored')
    end
  end

  describe '#camelcase_to_snakecase_symbol' do
    let(:camel) {'LookAtThisHumpyOldCamel'}

    it 'converts a camelcase string to a snakecase symbol equivalent' do
      expect(camelcase_to_snakecase_symbol(camel)).to eq(:look_at_this_humpy_old_camel)
    end
  end
end
