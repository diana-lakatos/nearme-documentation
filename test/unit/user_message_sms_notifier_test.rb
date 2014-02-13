require 'test_helper'

class UserMessageSmsNotifierTest < ActiveSupport::TestCase

  setup do
    @author = FactoryGirl.create(:user, :name => "Krzysztof Test")
    @recipient = FactoryGirl.create(:user, :mobile_number => "124456789")
    @recipient.stubs(:temporary_token).returns('abc')
    @user_message = FactoryGirl.create(:user_message,
                                       thread_context: @recipient,
                                       thread_owner: @author,
                                       author: @author,
                                       thread_recipient: @recipient,
                                       body: 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum.'
                                      )
    @instance = FactoryGirl.create(:instance, :name => 'DesksNearMe')
    @domain = FactoryGirl.create(:domain, :name => 'notifcations.com', :target => @instance)
    @platform_context = PlatformContext.new.initialize_with_instance(@instance)
    Googl.stubs(:shorten).with("http://notifcations.com/users/#{@recipient.id}/user_messages/#{@user_message.id}?token=abc").returns(stub(:short_url => "http://goo.gl/abc324"))
  end

  context '#notify_user_about_new_message' do
    should "render with the user_message" do
      sms = UserMessageSmsNotifier.notify_user_about_new_message(@platform_context, @user_message)
      assert_equal @recipient.full_mobile_number, sms.to
      assert sms.body =~ /\[DesksNearMe\] New message from Krzysztof: \"Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invi...\"/i, "Sms body does not include expected content: #{sms.body}"
      assert sms.body =~ /http:\/\/goo.gl/
    end

    should "not render if user had disabled sms notification for new messages" do
      @recipient.sms_preferences = { :user_message => '0' }
      sms = UserMessageSmsNotifier.notify_user_about_new_message(@platform_context, @user_message)
      assert sms.is_a?(SmsNotifier::NullMessage)
      refute sms.deliver
    end
  end
end

