require 'test_helper'

class PlatformHomeControllerTest < ActionController::TestCase

  context 'static pages' do
    should 'render home page' do
      get :index
      assert_template :index
    end

    should 'render get in touch page' do
      get :get_in_touch
      assert_template :get_in_touch
    end
  end

  context 'create platform email and inquiries' do
    should 'create platform_email' do
      assert_difference 'PlatformEmail.count', 1 do
        post :notify_me, platform_email: {"email"=>"binding@pry.com"}
      end
    end

    should 'create platform_inquiry' do
      assert_difference 'PlatformInquiry.count', 1 do
        post :save_inquiry, "platform_inquiry"=>
                            {"name"=>"Daniel",
                             "surname"=>"Docker",
                             "email"=>"daniel@docker.com",
                             "industry"=>"Shipping",
                             "message"=>"I would like to learn more, please send me an email."}
      end
    end
  end

  should 'send an email to a friend' do
    assert_difference 'ActionMailer::Base.deliveries.count', 2 do
      post :send_email, "email_data"=>{"emails"=>"dave@smith.com, susan@smith.com", "your_name"=>"Dan Smith"}
    end
  end

  context 'change subscription status nearme mailing list' do
    setup do
      @platform_email = FactoryGirl.create(:platform_email)
    end

    should 'unsubscribe' do
      verifier = ActiveSupport::MessageVerifier.new(DesksnearMe::Application.config.secret_token)
      unsubscribe_key = verifier.generate(@platform_email.email)
      post :unsubscribe, unsubscribe_key: unsubscribe_key
      @platform_email.reload
      assert @platform_email.unsubscribed?, "Platform_email failed to unsubscribe."
    end

    should 'resubscribe' do
      verifier = ActiveSupport::MessageVerifier.new(DesksnearMe::Application.config.secret_token)
      resubscribe_key = verifier.generate(@platform_email.email)
      post :resubscribe, resubscribe_key: resubscribe_key
      @platform_email.reload
      assert @platform_email.subscribed?, "Platform_email failed to re-subscribe."
    end
  end
end
