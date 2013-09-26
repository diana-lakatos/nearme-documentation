require 'test_helper'

class CompileThemeJobTest < ActiveSupport::TestCase
  context '#perform' do
    should "trigger the Theme compilation handler" do
      theme = stub()
      compiler_mock = mock(:generate_and_update_assets => true)
      Theme::Compiler.expects(:new).with(theme).returns(compiler_mock)

      CompileThemeJob.new(theme).perform
    end
  end
end
