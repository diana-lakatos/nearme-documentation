require 'test_helper'

class V1::SocialProviderControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @user.ensure_authentication_token!
    @request.headers['Authorization'] = @user.authentication_token
  end

  test 'raise DNM::Unauthorized when the uid exists for another user' do
    User.any_instance.stubs(:linked_to?).with('facebook').returns(true)
    info = stub(hash: { 'uid' => '123', 'name' => 'John Smith' }, uid: '123')
    Authentication::FacebookProvider.any_instance.stubs(:info).returns(info)
    Authentication.stubs(:where).returns([stub(user: nil)])

    assert_raise DNM::Unauthorized do
      raw_put :update, { provider: 'facebook' }, '{ "token": "abc123" }'
    end
  end

  test 'should get facebook data' do
    User.any_instance.stubs(:linked_to?).with('facebook').returns(false)

    get :show, provider: 'facebook'
    assert_response :success

    json = JSON.parse response.body
    assert json
  end

  test 'should update facebook data' do
    User.any_instance.stubs(:linked_to?).with('facebook').returns(true)
    info = stub(hash: { 'uid' => '123', 'name' => 'John Smith' }, uid: '123')
    Authentication::FacebookProvider.any_instance.stubs(:info).returns(info)

    raw_put :update, { provider: 'facebook' }, '{ "token": "abc123" }'
    assert_response :success

    json = JSON.parse response.body
    assert json['facebook']['linked']
  end

  test 'should delete facebook data' do
    User.any_instance.stubs(:linked_to?).with('facebook').returns(false)

    delete :destroy, provider: 'facebook'
    assert_response :success

    json = JSON.parse response.body
    refute json['facebook']['linked']
  end

  test 'should get twitter data' do
    User.any_instance.stubs(:linked_to?).with('twitter').returns(false)

    info = stub(hash: { 'uid' => '123', 'name' => 'John Smith' }, uid: '123')
    Authentication::TwitterProvider.any_instance.stubs(:info).returns(info)

    get :show, provider: 'twitter'
    assert_response :success

    json = JSON.parse response.body
    assert json
  end

  test 'should update twitter data' do
    User.any_instance.stubs(:linked_to?).with('twitter').returns(true)
    info = stub(hash: { 'uid' => '123', 'name' => 'John Smith' }, uid: '123')
    Authentication::TwitterProvider.any_instance.stubs(:info).returns(info)

    raw_put :update, { provider: 'twitter' }, '{ "token": "abc123", "secret": "xyz789" }'
    assert_response :success

    json = JSON.parse response.body
    assert json['twitter']['linked']
  end

  test 'should delete twitter data' do
    User.any_instance.stubs(:linked_to?).with('twitter').returns(false)

    delete :destroy, provider: 'twitter'
    assert_response :success

    json = JSON.parse response.body
    refute json['twitter']['linked']
  end

  test 'should get linkedin data' do
    User.any_instance.stubs(:linked_to?).with('linkedin').returns(true)

    get :show, provider: 'linkedin'
    assert_response :success

    json = JSON.parse response.body
    assert json
  end

  test 'should update linkedin data' do
    User.any_instance.stubs(:linked_to?).with('linkedin').returns(true)
    info = stub(hash: { 'uid' => '123', 'name' => 'John Smith' }, uid: '123')
    Authentication::LinkedinProvider.any_instance.stubs(:info).returns(info)

    raw_put :update, { provider: 'linkedin' }, '{ "token": "abc123", "secret": "xyz789" }'
    assert_response :success

    json = JSON.parse response.body
    assert json['linkedin']['linked']
  end

  test 'should delete linkedin data' do
    User.any_instance.stubs(:linked_to?).with('linkedin').returns(false)

    delete :destroy, provider: 'linkedin'
    assert_response :success

    json = JSON.parse response.body
    refute json['linkedin']['linked']
  end
end
