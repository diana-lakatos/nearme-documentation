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
      PlatformMailer.expects(:contact_request).returns(stub(deliver: true))
      platform_contact = FactoryGirl.attributes_for(:platform_contact)
      assert_difference 'PlatformContact.count', 1 do
        post :contact_submit, platform_contact: platform_contact
      end
    end

    should 'create platform demo request' do
      PlatformMailer.expects(:demo_request).returns(stub(deliver: true))
      platform_demo_request = FactoryGirl.attributes_for(:platform_demo_request)
      assert_difference 'PlatformDemoRequest.count', 1 do
        post :demo_request_submit, platform_demo_request: platform_demo_request
      end
    end
  end
end
