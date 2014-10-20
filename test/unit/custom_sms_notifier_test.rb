require 'test_helper'
class CustomSmsNotifierTest < ActiveSupport::TestCase
  module DummyWorkflow
    class DummyStep < WorkflowStep::BaseStep

    def initialize(dummy_arg, user)
      @dummy_arg = dummy_arg
      @user = user
    end

    def lister
      'a'
    end

    def enquirer
      'b'
    end

    def data
      { dummy_arg: @dummy_arg, user: @user}
    end

    end
  end

  setup do
    stub_mixpanel
    @user = FactoryGirl.create(:user, name: 'John Doe')
    @step = DummyWorkflow::DummyStep.new('dummy value', @user)
    @render_response = "Hello John Doe"
    @to = "1234"
    @from = "4567"
    @sms_template = FactoryGirl.create(:instance_view_sms)
    CustomSmsNotifier.any_instance.stubs(:options).returns({to: @to, from: @from, template_name: @sms_template.path})
    WorkflowAlert.stubs(:find).returns(stub())
    CustomSmsNotifier.any_instance.stubs(:user).returns(@user)
  end

  should "send correct custom sms" do
    sms = CustomSmsNotifier.custom_sms(@step , 1)
    assert sms.instance_of?(SmsNotifier::Message)
    assert_equal @to, sms.to
    assert_equal @from, sms.from
    assert_equal @render_response, sms.body
  end

end

