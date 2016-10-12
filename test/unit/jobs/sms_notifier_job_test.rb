require 'test_helper'

class SmsNotifierJobTest < ActiveSupport::TestCase
  context 'logger' do
    setup do
      WorkflowAlertLogger.setup { |config| config.logger_type = :db }
      @sms = stub
      @workflow_alert = stub
      WorkflowAlert.stubs(:find).with(1).returns(@workflow_alert)
      CustomSmsNotifier.stubs(:custom_sms).returns(@sms)
    end

    should 'create correct log entry for sms if deliver' do
      @sms.stubs(:deliver!).returns(true)
      WorkflowAlertLogger.any_instance.expects(:db_log!)
      SmsNotifierJob.perform(CustomSmsNotifier, :custom_sms, stub, 1)
    end

    should 'not create log entry if sms not delivered' do
      @sms.stubs(:deliver!).returns(false)
      WorkflowAlertLogger.any_instance.expects(:db_log!).never
      SmsNotifierJob.perform(CustomSmsNotifier, :custom_sms, stub, 1)
    end

    should 'not create log entry if error raised during delivery' do
      WorkflowAlertLogger.any_instance.expects(:db_log!).never
      @sms.stubs(:deliver!).raises(StandardError)
      assert_raise StandardError do
        SmsNotifierJob.perform(CustomSmsNotifier, :custom_sms, stub, 1)
      end
    end

    teardown do
      WorkflowAlertLogger.setup { |config| config.logger_type = :none }
    end
  end
end
