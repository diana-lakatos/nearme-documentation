require 'test_helper'

class InstanceTheme::CompilerTest < ActiveSupport::TestCase
  def setup
    @instance = FactoryGirl.create(:instance)
    @instance_theme = InstanceTheme.new.skipping_compilation do |theme|
      theme.instance = @instance
      theme.save!
    end
  end

  context '#generate_and_update_assets' do
    should 'compile a css file and save it to the Theme' do
      compiler = InstanceTheme::Compiler.new(@instance_theme)
      compiler.generate_and_update_assets

      assert @instance_theme.compiled_stylesheet.present?
      assert @instance_theme.compiled_stylesheet.read =~ /#logo/,
        "Expected to see a CSS rule"
    end
  end
end

