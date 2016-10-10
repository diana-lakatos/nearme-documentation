require 'test_helper'

class V1::AuthenticationsControllerTest < ActionController::TestCase
  PASSWORD = 'password123'

  setup do
    @user = FactoryGirl.build(:user)
    @user.password = @user.password_confirmation = PASSWORD
    @user.save!
  end

  ##
  # Email/Password Authentication

  test 'should authenticate valid credentials' do
    raw_post :create, {}, auth_hash.to_json
    assert_response :success

    @user.reload
    @json = JSON.parse(@response.body)
    assert_equal @user.authentication_token, @json['token']
  end

  test 'search should raise when given invalid credentials' do
    assert_raise DNM::Unauthorized do
      raw_post :create, {}, auth_hash.merge(password: 'nope').to_json
    end
  end

  ##
  # Social Authentication

  test 'social should authenticate valid social credentials' do
    @user.authentications.where(provider: 'facebook').first_or_create.tap do |a|
      a.uid = '123456'
      a.token = '123456'
    end.save!

    info = stub(to_hash: { 'uid' => '123456', 'name' => @user.name }, uid: '123456')
    Authentication::FacebookProvider.any_instance.stubs(:info).returns(info)

    raw_post :social, { provider: 'facebook' }, '{ "token": "abc123" }'
    assert_response :success

    @user.reload
    @json = JSON.parse(@response.body)
    assert_equal @user.authentication_token, @json['token']
  end

  test 'social should raise when given invalid social credentials' do
    assert_raise DNM::MissingJSONData do
      raw_post :social, { provider: 'facebook' }, '{ "notatoken": "nope" }'
    end
  end

  test "social should raise when valid social credentials aren't previously saved" do
    info = stub(to_hash: { 'uid' => '123456', 'name' => @user.name }, uid: nil)
    Authentication::FacebookProvider.any_instance.stubs(:info).returns(info)

    assert_raise DNM::Unauthorized do
      raw_post :social, { provider: 'facebook' }, '{ "token": "abc123" }'
    end
  end

  test "social should raise when valid social credentials aren't previously saved but a user with that email exists" do
    @user.save # Make sure the user can be found in the db
    info = stub(to_hash: { 'uid' => '123456', 'name' => @user.name, 'email' => @user.email }, uid: '123456')
    Authentication::FacebookProvider.any_instance.stubs(:info).returns(info)

    assert_raise DNM::UnauthorizedButUserExists do
      raw_post :social, { provider: 'facebook' }, '{ "token": "abc123" }'
    end
  end

  private

  def auth_hash
    { email: @user.email, password: PASSWORD }
  end
end
