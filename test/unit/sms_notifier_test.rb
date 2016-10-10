require 'test_helper'
class SmsNotifierTest < ActiveSupport::TestCase
  setup do
    @render_response = 'test'
    @to = '1234'
    @from = '4567'
    @concrete_notifier = Class.new(SmsNotifier) do
      def sample_message(options)
        sms(options)
      end
    end
  end

  context '.sample_message' do
    should 'return a SmsNotifier::Message instance with correct data' do
      @concrete_notifier.any_instance.expects(:render_message).returns(@render_response)
      sms = @concrete_notifier.sample_message(to: @to, from: @from)
      assert sms.instance_of?(SmsNotifier::Message)
      assert_equal @to, sms.to
      assert_equal @from, sms.from
      assert_equal @render_response, sms.body
    end

    should 'only render from template if no body given' do
      @concrete_notifier.any_instance.expects(:render_message).never
      sms = @concrete_notifier.sample_message(to: @to, from: @from, body: 'from string')
      assert_equal 'from string', sms.body
    end
  end

  context 'Message' do
    context 'twilio client config' do
      should 'get test config by default' do
        SmsNotifier::Message::DummyTwilioClient.expects(:new).with('test_tc1', 'test_tc2')
        @message = SmsNotifier::Message.new(to: '1', from: '2', body: 'test')
        @message.send(:build_twilio_client)
      end

      should 'get default config if instance has blank twilio key' do
        PlatformContext.current.instance.update_attribute(:test_twilio_consumer_key, '')
        SmsNotifier::Message::DummyTwilioClient.expects(:new).with('AC83d13764f96b35292203c1a276326f5d', '709625e20011ace4b8b53a5a04160026')
        @message = SmsNotifier::Message.new(to: '1', from: '2', body: 'test')
        @message.send(:build_twilio_client)
      end

      should 'get default config if instance has blank twilio secret' do
        PlatformContext.current.instance.update_attribute(:test_twilio_consumer_secret, '')
        SmsNotifier::Message::DummyTwilioClient.expects(:new).with('AC83d13764f96b35292203c1a276326f5d', '709625e20011ace4b8b53a5a04160026')
        @message = SmsNotifier::Message.new(to: '1', from: '2', body: 'test')
        @message.send(:build_twilio_client)
      end

      should 'get default config if instance has blank twilio from number' do
        PlatformContext.current.instance.update_attribute(:test_twilio_from_number, '')
        SmsNotifier::Message::DummyTwilioClient.expects(:new).with('AC83d13764f96b35292203c1a276326f5d', '709625e20011ace4b8b53a5a04160026')
        @message = SmsNotifier::Message.new(to: '1', from: '2', body: 'test')
        @message.send(:build_twilio_client)
      end
    end

    context '#deliver' do
      setup do
        @sms_client = stub
        SmsNotifier::Message.any_instance.stubs(:twilio_client).returns(stub(account: stub(sms: stub(messages: @sms_client))))
      end

      should 'trigger twilio delivery' do
        message = SmsNotifier::Message.new(to: '1', from: '2', body: 'test')
        @sms_client.expects(:create).with(to: '1', from: '2', body: 'test')
        assert message.deliver
      end

      should 'raise an exception if message body size is greater than 160 chars' do
        message = SmsNotifier::Message.new(to: '1', from: '2', body: 'w' * 200)
        Rails.application.config.marketplace_error_logger.class.any_instance.stubs(:log_issue).with do |error_type, msg|
          error_type == MarketplaceErrorLogger::BaseLogger::SMS_ERROR && msg.include?('w' * 200) && msg.include?('200')
        end
        refute message.deliver
      end
    end
  end
end
