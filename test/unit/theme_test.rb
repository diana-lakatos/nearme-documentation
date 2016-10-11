require 'test_helper'

class ThemeTest < ActiveSupport::TestCase
  setup do
    @instance = FactoryGirl.create(:instance)
  end

  context '#hex_color' do
    setup do
      @name = Theme::COLORS.first
      @theme = @instance.theme
    end
    should 'return color with # if color method exists' do
      color = '123456'
      @theme.send(:"color_#{@name}=", color)
      assert_equal "##{color}", @theme.hex_color(@name)
    end

    should 'return blank string if color is nil' do
      color = nil
      @theme.send(:"color_#{@name}=", color)
      assert_equal '', @theme.hex_color(@name)
    end

    should 'raise InvalidArgumentError when color is not defined' do
      @name = 'test_color'
      assert_raises(ArgumentError) { @theme.hex_color(@name) }
    end
  end

  context '::hexify' do
    should 'format hex color with #' do
      assert_equal '#006699', Theme.hexify('006699')
      assert_equal '#006699', Theme.hexify('#006699')
    end
  end

  context '::unhexify' do
    should 'format hex color without #' do
      assert_equal '006699', Theme.unhexify('006699')
      assert_equal '006699', Theme.unhexify('#006699')
    end
  end

  context 'colors are unhexified' do
    setup do
      @theme = FactoryGirl.build(:theme)
    end

    should 'receive hexified values' do
      @theme.color_blue = '#006699'
      assert @theme.valid?
      assert_equal '006699', @theme.color_blue
    end

    should 'receive unhexified values' do
      @theme.color_blue = '006699'
      assert @theme.valid?
      assert_equal '006699', @theme.color_blue
    end
  end
end
