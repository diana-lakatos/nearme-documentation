require 'test_helper'

class AuthenticationTest < ActiveSupport::TestCase
  should validate_presence_of(:provider)
  should validate_presence_of(:uid)

  should validate_uniqueness_of(:provider).scoped_to(:user_id)
  should validate_uniqueness_of(:uid).scoped_to(:provider)

  setup do
    @user = FactoryGirl.build(:user, password: nil)
    @user.save!(validate: false)

    @valid_params = { :provider => "desksnearme",
                      :uid      => "123456789",
                      :user_id  => @user.id }
  end

  should "has a hash for info" do
    auth = Authentication.new(@valid_params)
    auth.info["thing"] = "stuff"
    assert_equal "stuff", auth.info["thing"]
  end

  context '#can_be_deleted?' do
    should "not be deleted if user has nil password and he has no other authentications" do
      auth = Authentication.new(@valid_params, :user => User.new)
      auth.user.authentications << auth
      assert_equal false, auth.can_be_deleted?
    end

    should "not be deleted if user has blank password and he has no other authentications" do
      auth = Authentication.new(@valid_params, :user => User.new)
      auth.user.encrypted_password = ''
      auth.user.authentications << auth
      assert_equal false, auth.can_be_deleted?
    end

    should "be deleted if user has not blank password and he has no other authentications" do
      auth = Authentication.new(@valid_params, :user => User.new)
      auth.user.encrypted_password = "aaaaaa"
      auth.user.authentications << auth
      assert_equal true, auth.can_be_deleted?
    end

    should "be deleted if user has blank password but he has other authentications" do
      auth = Authentication.new(@valid_params, :user => User.new)
      auth.user.encrypted_password = ""
      auth.user.authentications << Authentication.new
      auth.user.authentications << auth
      assert_equal true, auth.can_be_deleted?
    end

    should "be deleted if user has not blank password and he has other authentications" do
      auth = Authentication.new(@valid_params, :user => User.new)
      auth.user.encrypted_password = "aaaaaa"
      auth.user.authentications << auth
      auth.user.authentications << Authentication.new
      assert_equal true, auth.can_be_deleted?
    end
  end
end
