require 'test_helper'

class AuthenticationTest < ActiveSupport::TestCase
  setup do
    @valid_params = { :provider => "desksnearme",
                      :uid      => "123456789",
                      :user_id  => 16 }
  end

  test "is valid with valid params" do
    auth = Authentication.new @valid_params
    assert auth.valid?
  end

  test "needs a provider to be valid" do
    params = @valid_params.clone
    params.delete :provider
    auth = Authentication.new params
    refute auth.valid?
    assert auth.errors[:provider].include?("can't be blank")
  end

  test "needs a uid to be valid" do
    params = @valid_params.clone
    params.delete :uid
    auth = Authentication.new params
    refute auth.valid?
    assert auth.errors[:uid].include?("can't be blank")
  end

  test "has a hash for info" do
    auth = Authentication.new(@valid_params)
    auth.info["thing"] = "stuff"
    assert_equal "stuff", auth.info["thing"]
  end

  test "cannot be deleted if user has nil password and he has no other authentications" do
    auth = Authentication.new(@valid_params, :user => User.new)
    auth.user.authentications << auth
    assert_equal false, auth.can_be_deleted?
  end

  test "cannot be deleted if user has blank password and he has no other authentications" do
    auth = Authentication.new(@valid_params, :user => User.new)
    auth.user.encrypted_password = ''
    auth.user.authentications << auth
    assert_equal false, auth.can_be_deleted?
  end

  test "can be deleted if user has not blank password and he has no other authentications" do
    auth = Authentication.new(@valid_params, :user => User.new)
    auth.user.encrypted_password = "aaaaaa"
    auth.user.authentications << auth
    assert_equal true, auth.can_be_deleted?
  end

  test "can be deleted if user has blank password but he has other authentications" do
    auth = Authentication.new(@valid_params, :user => User.new)
    auth.user.encrypted_password = ""
    auth.user.authentications << Authentication.new
    auth.user.authentications << auth
    assert_equal true, auth.can_be_deleted?
  end

  test "can be deleted if user has not blank password and he has other authentications" do
    auth = Authentication.new(@valid_params, :user => User.new)
    auth.user.encrypted_password = "aaaaaa"
    auth.user.authentications << auth
    auth.user.authentications << Authentication.new
    assert_equal true, auth.can_be_deleted?
  end
end
