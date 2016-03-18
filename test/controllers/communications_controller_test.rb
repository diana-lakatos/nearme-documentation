require 'test_helper'

class CommunicationsControllerTest < ActionController::TestCase

  setup do
    @provider = Struct.new(:verify_number, :disconnect_number).new
    @caller = Struct.new(:account_sid, :phone_number, :call_sid, :validation_code).new
    @user = FactoryGirl.create(:user)

    @controller.stubs(:client).returns(@provider)
    @controller.stubs(:current_user).returns(@user)

    sign_in @user
  end

  test "#create verifies user's number" do
    @provider.expects(:verify_number)
      .with(@user.name, @user.full_mobile_number, 'http://example.com/webhooks/communications/status')
      .returns(@caller)

    post :create, user_id: @user.id
  end

  test '#create creates unverified communication' do
    @caller.stubs(account_sid: 'abc', phone_number: '+00000000000', call_sid: '123')
    @provider.stubs(:verify_number).returns(@caller)

    @user.expects(:build_communication).with({
      provider: 'twilio',
      provider_key: 'abc',
      phone_number: '+00000000000',
      phone_number_key: nil,
      request_key: '123',
      verified: false
    })

    post :create, user_id: @user.id
  end

  test "#create redirects to 'Trust & Verification' with validation code" do
    @caller.stubs(account_sid: 'abc', phone_number: '+00000000000', call_sid: '123', validation_code: 'xyz')
    @provider.stubs(:verify_number).returns(@caller)
    post :create, user_id: @user.id

    assert_equal flash[:notice], I18n.t('flash_messages.communications.validation_code', validation_code: @caller.validation_code)
    assert_redirected_to social_accounts_path
  end

  test '#destroy disconnects verified number' do
    communication = Struct.new(:destroy).new
    communication.stubs(:phone_number_key).returns('+00000000000')
    @user.stubs(:communication).returns(communication)

    @provider.expects(:disconnect_number).with('+00000000000')

    delete :destroy, user_id: @user.id, id: @user.id
  end

  test '#destroy destroyes verified communication' do
    communication = Struct.new(:destroy, :phone_number_key).new
    @user.stubs(:communication).returns(communication)
    @provider.stubs(:disconnect_number)

    communication.expects(:destroy)

    delete :destroy, user_id: @user.id, id: @user.id
  end

  test "#destroy redirects to 'Trust & Verification'" do
    communication = Struct.new(:destroy, :phone_number_key).new
    @user.stubs(:communication).returns(communication)
    @provider.stubs(:disconnect_number)
    delete :destroy, user_id: @user.id, id: @user.id

    assert_redirected_to social_accounts_path
  end

end
