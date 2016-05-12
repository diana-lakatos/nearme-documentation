require 'test_helper'

class PhoneCallsControllerTest < ActionController::TestCase

  setup do
    @provider = Struct.new(:call, :hang_up).new
    @caller = Struct.new(:sid).new

    @current_instance = FactoryGirl.create(:instance)
    @current_user = FactoryGirl.create(:user_with_verified_phone_number)
    @user = FactoryGirl.create(:user_with_verified_phone_number)

    @controller.stubs(:current_instance).returns(@current_instance)
    @controller.stubs(:current_user).returns(@current_user)
    @controller.stubs(:client).returns(@provider)

    User.stubs(:find).returns(@user)

    sign_in @user
  end

  test "#create makes a call" do
    @caller.stubs(:sid).returns('123')

    @provider.expects(:call).with(
      to: @current_user.communication.phone_number,
      from: @current_instance.twilio_config[:from],
      url: connect_webhooks_phone_calls_url,
      status_callback: status_webhooks_phone_calls_url
    ).returns(@caller)

    xhr :post, :create, user_id: @current_user.id
  end

  test '#create creates a phone call' do
    @caller.stubs(:sid).returns('123')
    @provider.stubs(:call).returns(@caller)

    phone_call = Struct.new(:create)
    @current_user.stubs(:outgoing_phone_calls).returns(phone_call)

    phone_call.expects(:create).with({
      from: @current_user.communication.phone_number,
      receiver_id: @user.id,
      to: @user.communication.phone_number,
      phone_call_key: @caller.sid
    })

    xhr :post, :create, user_id: @current_user.id
  end

  test '#destroy terminates running call' do
    @provider.expects(:hang_up).with('123')

    xhr :delete, :destroy, user_id: @current_user.id, id: '123'
  end

end
