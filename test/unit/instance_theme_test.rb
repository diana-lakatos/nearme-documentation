require 'test_helper'

class InstanceThemeTest < ActiveSupport::TestCase
  def setup
    @instance = FactoryGirl.create(:instance)
  end

  context 'creating' do
    should "trigger a compilation of the theme" do
      theme = InstanceTheme.new
      theme.instance = @instance

      CompileInstanceThemeJob.expects(:perform).with(theme)
      theme.save!
    end
  end

  context 'updating' do
    setup do
      @instance_theme = InstanceTheme.new.skipping_compilation do |theme|
        theme.instance = @instance
        theme.save!
      end
    end

    should "trigger compilation of the theme after changing relevant fields" do
      @instance_theme.color_red = 'red'

      CompileInstanceThemeJob.expects(:perform).with(@instance_theme)
      @instance_theme.save!
    end

    should "not trigger compilation if no relevant fields changed" do
      CompileInstanceThemeJob.expects(:perform).never
      @instance_theme.save!
    end
  end
end

