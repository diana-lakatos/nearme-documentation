require 'test_helper'

class AuthenticationsControllerTest < ActionController::TestCase

  include Devise::TestHelpers
  PASSWORD = "password123"

  setup do
  end


  # Social Authentication


  test "authentication can be deleted if user has password set" do
    create_signed_in_user_with_authentication
    assert_difference('@user.authentications.count', -1) do
      delete :destroy, id: @user.authentications.first.id
    end
  end

  test "authentication can be deleted if user has no  password but more than one authentications" do
    create_signed_in_user_with_authentication
    add_authentication("twitter", "abc123")
    assert_difference('@user.authentications.count', -1) do
      delete :destroy, id: @user.authentications.first.id
    end
  end

  test "authentication cannot be deleted if user has no password and one authentication" do
    create_no_password_signed_in_user_and_authentication
    assert_difference('@user.authentications.count', 0) do
      delete :destroy, id: @user.authentications.first.id
    end
  end

  private

  def add_authentication(provider, uid)
    @user.authentications.find_or_create_by_provider(provider).tap do |a|
      a.uid = uid
    end.save!
  end

  def create_no_password_signed_in_user_and_authentication
    create_signed_in_user_with_authentication(false)
  end

  def create_signed_in_user_with_authentication(with_password = true)
    @user = users(:one)
    @user.password = PASSWORD if with_password
    @user.save!
    sign_in @user
    add_authentication("facebook", "123456")
    @user.authentications.each do |auth|
      auth.user = @user
      auth.user.save!
    end
  end

end
