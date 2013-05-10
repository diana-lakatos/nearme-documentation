require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
     @user = FactoryGirl.create(:user)
     @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  context "verify" do

    should "verify user if token and id are correct" do
      get :verify, :id => @user.id, :token => @user.email_verification_token
      @user.reload
      assert @user.verified
    end

    should "handle situation when user is verified" do
      @user.verified = true
      @user.save!
      get :verify, :id => @user.id, :token => @user.email_verification_token
      @user.reload
      assert @user.verified
    end

    should "not verify user if id is incorrect" do
      get :verify, :id => (@user.id+1), :token => @user.email_verification_token
      @user.reload
      assert !@user.verified
    end

    should "not verify user if token is incorrect" do
      get :verify, :id => @user.id, :token => @user.email_verification_token+"incorrect"
      @user.reload
      assert !@user.verified
    end

  end
end
