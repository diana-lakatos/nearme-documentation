require 'test_helper'

class User::TemporaryTokenVerifierTest < ActiveSupport::TestCase
  def setup
    @user = FactoryGirl.create(:user)
    @verifier = User::TemporaryTokenVerifier.new(@user)
  end

  context '#generate' do
    should "return a token" do
      assert @verifier.generate.present?
    end

    should "differ depending on expiry time" do
      assert_not_equal @verifier.generate(3.days.from_now), @verifier.generate(4.days.from_now)
    end
  end

  context '.find_user_for_token' do
    should "take a valid token and return the given user" do
      token = @verifier.generate
      assert_equal @user, User::TemporaryTokenVerifier.find_user_for_token(token)
    end

    should "return nil if the token is invalid" do
      assert_nil User::TemporaryTokenVerifier.find_user_for_token("somerandomstuff")
    end

    should "return nil if the token has expired" do
      token = @verifier.generate(1.minute.ago)
      assert_nil User::TemporaryTokenVerifier.find_user_for_token(token)
    end

    should "return nil if the user's password changes" do
      token = @verifier.generate(7.days.from_now)
      @user.password = 'somethingelse'
      @user.save(validate: false)

      assert_nil User::TemporaryTokenVerifier.find_user_for_token(token)
    end

    should "return nil if someone changes the expiry time" do
      token = @verifier.generate(1.day.ago)
      data, digest = token.split('--')
      tomorrow = 1.day.from_now
      token = [Base64.encode64("#{@user.id}|#{tomorrow.to_i}"), digest].join '--'

      assert_nil User::TemporaryTokenVerifier.find_user_for_token(token)
    end
  end
end
