require 'test_helper'

class CompileInstanceThemeJobTest < ActiveSupport::TestCase
  context '#perform' do
    should "trigger the Theme compilation handler" do
      theme = stub()
      compiler_mock = mock(:generate_and_update_assets => true)
      InstanceTheme::Compiler.expects(:new).with(theme).returns(compiler_mock)

      CompileInstanceThemeJob.new(theme).perform
    end
  end
end
