require 'test_helper'

class PlatformHomeControllerTest < ActionController::TestCase

  context 'static pages' do
    should 'render home page' do
      get :index
      assert_template :index
    end

    should 'render features page' do
      get :features
      assert_template :features
    end
  end

  context 'create platform contact' do

    should 'create platform contact' do
      assert_difference 'PlatformContact.count', 1 do
        post :contact_submit, "platform_contact"=>
                                   {"name"       => "Daniel Docker",
                                    "email"      => "docker@gmail.com",
                                    "subject"    => "I'm interested.",
                                    "comments"   => "I would like to learn more, please send me an email.",
                                    "subscribed" => true }
      end
    end

    should 'create platform demo request' do
      assert_difference 'PlatformDemoRequest.count', 1 do
        post :demo_request_submit, "platform_demo_request"=>
                                   {"name"       => "Daniel Docker",
                                    "email"      => "docker@gmail.com",
                                    "company"    => "Docker, Co.",
                                    "phone"      => "317 867 5309",
                                    "comments"   => "I would like to learn more, please send me an email.",
                                    "subscribed" => true }
      end
    end
  end
end
