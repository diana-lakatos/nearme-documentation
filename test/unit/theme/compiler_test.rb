require 'test_helper'

class Theme::CompilerTest < ActiveSupport::TestCase
  def setup
    @instance = FactoryGirl.create(:instance)
    @theme = Theme.new.skipping_compilation do |theme|
      theme.owner = @instance
      theme.save!
    end
  end

  context '#generate_and_update_assets' do
    should 'compile a css file and save it to the Theme' do
      compiler = Theme::Compiler.new(@theme)
      compiler.generate_and_update_assets

      assert @theme.compiled_stylesheet.present?
      assert @theme.compiled_stylesheet.read =~ /#logo/,
        "Expected to see a CSS rule"
    end
  end
end

