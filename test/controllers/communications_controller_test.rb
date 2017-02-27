require 'test_helper'

class CommunicationsControllerTest < ActionController::TestCase
  setup do
    @provider = Struct.new(:verify_number, :disconnect_number, :get_by_phone_number).new
    @caller = Struct.new(:account_sid, :phone_number, :call_sid, :validation_code, :sid).new
    @user = FactoryGirl.create(:user)

    @controller.stubs(:client).returns(@provider)
    @controller.stubs(:current_user).returns(@user)

    sign_in @user
  end

  test '#create checks for existing user based on user mobile number' do
    @provider.stubs(:get_by_phone_number).returns(@caller)

    @provider.expects(:get_by_phone_number)
      .with(@user.full_mobile_number)
      .returns(@caller)

    post :create, user_id: @user.id
  end

  test '#create checks for existing user based on number as a param' do
    @provider.stubs(:get_by_phone_number).returns(@caller)

    @provider.expects(:get_by_phone_number)
      .with('+123')
      .returns(@caller)

    post :create, user_id: @user.id, phone: '+123'
  end

  test "#create adds new communication if user doesn't exist on provider" do
    @provider.stubs(:get_by_phone_number).returns(nil)

    @provider.expects(:verify_number)
      .with(@user.name, @user.full_mobile_number, 'http://example.com/webhooks/communications/status')
      .returns(@caller)

    post :create, user_id: @user.id
  end

  test '#create creates unverified communication for non existing user' do
    @provider.stubs(:get_by_phone_number).returns(nil)

    @caller.stubs(account_sid: 'abc', phone_number: '+00000000000', call_sid: '123')
    @provider.stubs(:verify_number).returns(@caller)

    @user.expects(:build_communication).with(provider: 'twilio',
                                             provider_key: 'abc',
                                             phone_number: '+00000000000',
                                             phone_number_key: nil,
                                             request_key: '123',
                                             verified: false)

    post :create, user_id: @user.id
  end

  test "#create shouldn't call verification for validated users" do
    @provider.stubs(:get_by_phone_number).returns(@caller)

    @provider.expects(:verify_number).never

    post :create, user_id: @user.id
  end

  test '#create creates verified communication for verified users' do
    @caller.stubs(account_sid: 'abc', phone_number: '+00000000000', call_sid: '123', sid: 'SID')
    @provider.stubs(:get_by_phone_number).returns(@caller)

    @user.expects(:build_communication).with(provider: 'twilio',
                                             provider_key: 'abc',
                                             phone_number: '+00000000000',
                                             phone_number_key: 'SID',
                                             request_key: nil,
                                             verified: true)

    post :create, user_id: @user.id
  end

  test "#create redirects to 'Click to Call' with validation code" do
    @caller.stubs(account_sid: 'abc', phone_number: '+00000000000', call_sid: '123', validation_code: 'xyz')
    @provider.stubs(:get_by_phone_number).returns(nil)
    @provider.stubs(:verify_number).returns(@caller)
    post :create, user_id: @user.id

    assert_equal flash[:notice], I18n.t('flash_messages.communications.validation_code', validation_code: @caller.validation_code)
    assert_redirected_to edit_dashboard_click_to_call_preferences_path
  end

  test '#create generates correct JSON with validation code for non verified users' do
    @caller.stubs(account_sid: 'abc', phone_number: '+00000000000', call_sid: '123', validation_code: 'xyz')
    @provider.stubs(:get_by_phone_number).returns(nil)
    @provider.stubs(:verify_number).returns(@caller)
    xhr :post, :create, user_id: @user.id

    assert_equal 'new', json_response['status']
    assert_equal 'xyz', json_response['message']
    assert_equal verified_user_communications_path(@user), json_response['poll_url']
  end

  test '#create generates correct JSON for verified users' do
    @caller.stubs(account_sid: 'abc', phone_number: '+00000000000', call_sid: '123', validation_code: 'xyz')
    @provider.stubs(:get_by_phone_number).returns(@caller)

    xhr :post, :create, user_id: @user.id

    assert_equal 'verified', json_response['status']
    assert_equal '+00000000000', json_response['phone']
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

  test "#destroy redirects to 'Click to Call'" do
    communication = Struct.new(:destroy, :phone_number_key).new
    @user.stubs(:communication).returns(communication)
    @provider.stubs(:disconnect_number)
    delete :destroy, user_id: @user.id, id: @user.id

    assert_redirected_to social_accounts_path
  end

  test '#verified should return correct JSON for verified user' do
    communication = Struct.new(:verified?, :phone_number).new
    communication.stubs(:phone_number).returns('+1111')
    communication.stubs(:verified?).returns(true)
    @user.stubs(:communication).returns(communication)

    get :verified, user_id: @user.id

    assert json_response['status']
    assert_equal '+1111', json_response['phone']
  end

  test '#verified should return correct JSON for unverified user' do
    communication = Struct.new(:verified?).new
    communication.stubs(:verified?).returns(false)
    @user.stubs(:communication).returns(communication)

    get :verified, user_id: @user.id

    refute json_response['status']
  end

  private

  def json_response
    ActiveSupport::JSON.decode @response.body
  end
end
