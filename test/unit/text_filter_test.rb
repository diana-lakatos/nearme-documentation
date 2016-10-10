require 'test_helper'

class TextFilterTest < ActiveSupport::TestCase
  context 'validation' do
    setup do
      @text_filter = FactoryGirl.build(:text_filter)
    end

    should 'not be valid without name' do
      @text_filter.name = nil
      refute @text_filter.valid?
    end

    should 'be valid without replacecement text' do
      @text_filter.replacement_text = nil
      assert @text_filter.valid?
    end

    context 'regexp' do
      should 'not be valid without regexp' do
        @text_filter.regexp = nil
        refute @text_filter.valid?
      end

      should 'not be valid when regexp is wrong' do
        @text_filter.regexp = '(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})'
        refute @text_filter.valid?
      end

      should 'be valid when regexp is valid' do
        @text_filter.regexp = '\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})'
        assert @text_filter.valid?
      end
    end
  end
end
