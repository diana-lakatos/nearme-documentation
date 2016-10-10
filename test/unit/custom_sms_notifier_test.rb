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
        { dummy_arg: @dummy_arg, user: @user }
      end
    end
  end

  context 'general' do
    setup do
      @user = FactoryGirl.create(:user, name: 'John Doe')
      @step = DummyWorkflow::DummyStep.new('dummy value', @user)
      @render_response = 'Hello John Doe'
      @sms_template = FactoryGirl.create(:instance_view_sms)
      WorkflowAlert.stubs(:find).returns(stub(template_path: @sms_template.path, should_be_triggered?: true))
      CustomSmsNotifier.any_instance.stubs(:user).returns(@user)
    end

    context 'custom_sms' do
      should 'send correct custom sms' do
        sms = CustomSmsNotifier.custom_sms(@step, 1)
        assert sms.instance_of?(SmsNotifier::Message)
        assert_equal @user.full_mobile_number, sms.to
        assert_equal @render_response, sms.body
      end

      context 'association with transactable type' do
        setup do
          @transactable_type = FactoryGirl.create(:transactable_type)
          @transactable_type_sms_template = FactoryGirl.create(:instance_view_sms, transactable_types: [@transactable_type], body: 'Hello from transactable type')
        end

        should 'be able to find template associated with transactable type if data object associated with it' do
          @step.stubs(:transactable_type_id).returns(@transactable_type.id)
          sms = CustomSmsNotifier.custom_sms(@step, 1)
          assert_equal 'Hello from transactable type', sms.body
        end

        should 'ignore template associated with not related transactable type' do
          sms = CustomSmsNotifier.custom_sms(@step, 1)
          assert_equal @render_response, sms.body
        end
      end
    end
  end

  context 'liquid prevent trigger conditions' do
    setup do
      @user = FactoryGirl.create(:user, name: 'John Doe')
      @step = DummyWorkflow::DummyStep.new('dummy value', @user)
      @render_response = 'Hello John Doe'
      @sms_template = FactoryGirl.create(:instance_view_sms)
      CustomSmsNotifier.any_instance.stubs(:user).returns(@user)
    end

    should 'not send sms when prevent by liquid condition' do
      WorkflowAlert.stubs(:find).returns(stub(template_path: @sms_template.path, should_be_triggered?: false))
      sms = CustomSmsNotifier.custom_sms(@step, 1)
      assert sms.instance_of?(::SmsNotifier::NullMessage)
    end

    should 'send sms when not prevented by liquid condition' do
      WorkflowAlert.stubs(:find).returns(stub(template_path: @sms_template.path, should_be_triggered?: true))
      sms = CustomSmsNotifier.custom_sms(@step, 1)
      assert sms.instance_of?(SmsNotifier::Message)
    end
  end
end
