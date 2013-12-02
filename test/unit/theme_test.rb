require 'test_helper'

class ThemeTest < ActiveSupport::TestCase
  def setup
    @instance = FactoryGirl.create(:instance)
  end

  context 'creating' do
    should "trigger a compilation of the theme" do
      theme = Theme.new
      theme.owner = @instance

      CompileThemeJob.expects(:perform).with(theme)
      theme.save!
    end
  end

  context 'updating' do
    setup do
      @instance_theme = Theme.new.skipping_compilation do |theme|
        theme.owner = @instance
        theme.save!
      end
    end

    should "trigger compilation of the theme after changing relevant fields" do
      @instance_theme.color_red = 'ff0000'

      CompileThemeJob.expects(:perform).with(@instance_theme)
      @instance_theme.save!
    end

    should "not trigger compilation if no relevant fields changed" do
      CompileThemeJob.expects(:perform).never
      @instance_theme.save!
    end
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
      assert_equal "", @theme.hex_color(@name)
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

