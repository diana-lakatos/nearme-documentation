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
      @instance_theme.color_red = '#ff0000'

      CompileThemeJob.expects(:perform).with(@instance_theme)
      @instance_theme.save!
    end

    should "not trigger compilation if no relevant fields changed" do
      CompileThemeJob.expects(:perform).never
      @instance_theme.save!
    end
  end
end

