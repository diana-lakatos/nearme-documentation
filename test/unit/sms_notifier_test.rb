require 'test_helper'
class SmsNotifierTest < ActiveSupport::TestCase
  setup do
    @render_response = "test"
    @to = "1234"
    @from = "4567"
    @concrete_notifier = Class.new(SmsNotifier) do
      def sample_message(options)
        sms(options)
      end
    end

  end

  context '.sample_message' do
    should "return a SmsNotifier::Message instance with correct data" do
      @concrete_notifier.any_instance.expects(:render_message).returns(@render_response)
      sms = @concrete_notifier.sample_message(:to => @to, :from => @from)
      assert sms.instance_of?(SmsNotifier::Message)
      assert_equal @to, sms.to
      assert_equal @from, sms.from
      assert_equal @render_response, sms.body
    end

    should "only render from template if no body given" do
      @concrete_notifier.any_instance.expects(:render_message).never
      sms = @concrete_notifier.sample_message(:to => @to, :from => @from, :body => "from string")
      assert_equal "from string", sms.body
    end
  end

  context 'Message' do
    context '#deliver' do
      setup do
        @sms_client = stub()
        SmsNotifier::Message.twilio_client = stub(:account => stub(:sms => stub(:messages => @sms_client)))
      end

      should "trigger twilio delivery" do
        message = SmsNotifier::Message.new(:to => "1", :from => "2", :body => "test")
        @sms_client.expects(:create).with(:to => "1", :from => "2", :body => "test")
        message.deliver
      end
    end
  end
end

