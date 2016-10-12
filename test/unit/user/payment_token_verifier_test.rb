require 'test_helper'

class User::PaymentTokenVerifierTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @params = { 'a' => 'b' }
    @result = [@user, @params]
    @verifier = User::PaymentTokenVerifier.new(@user, @params)
  end

  context '#generate' do
    should 'return a token' do
      assert @verifier.generate.present?
    end

    should 'differ depending on expiry time' do
      assert_not_equal @verifier.generate(3.days.from_now), @verifier.generate(4.days.from_now)
    end
  end

  context '.find_token' do
    should 'take a valid token and return the given user' do
      token = @verifier.generate
      assert_equal @result, User::PaymentTokenVerifier.find_token(token)
    end

    should 'token can be used only once' do
      token = @verifier.generate
      User::PaymentTokenVerifier.find_token(token)
      assert_nil User::PaymentTokenVerifier.find_token(token)
    end

    should 'return nil if the token is invalid' do
      assert_nil User::PaymentTokenVerifier.find_token('somerandomstuff')
    end

    should 'return nil if the token has expired' do
      token = @verifier.generate(1.minute.ago)
      assert_nil User::PaymentTokenVerifier.find_token(token)
    end

    should "return nil if the user's password changes" do
      token = @verifier.generate(7.days.from_now)
      @user.password = 'somethingelse'
      @user.save(validate: false)

      assert_nil User::PaymentTokenVerifier.find_token(token)
    end

    should 'return nil if someone changes the expiry time' do
      token = @verifier.generate(1.day.ago)
      digest = token.split('--').last
      tomorrow = 1.day.from_now
      payment_token = @user.generate_payment_token
      token = [Base64.encode64("#{@user.id}|#{payment_token}|#{@params.to_json}|#{tomorrow.to_i}"), digest].join '--'

      assert_nil User::PaymentTokenVerifier.find_token(token)
    end

    should 'return nil if someone changes the params' do
      date = 1.day.ago
      token = @verifier.generate(date)
      digest = token.split('--').last
      payment_token = @user.generate_payment_token
      params = { 'c' => 'd' }.to_json
      token = [Base64.encode64("#{@user.id}|#{payment_token}|#{params}|#{date}"), digest].join '--'

      assert_nil User::PaymentTokenVerifier.find_token(token)
    end
  end
end
