require 'test_helper'

class PlatformHomeControllerTest < ActionController::TestCase

  context 'static pages' do
    should 'render home page' do
      get :index
      assert_template :index
    end
  end

  context 'create platform contact' do
    should 'create platform contact' do
      PlatformMailer.expects(:contact_request).returns(stub(deliver: true))
      platform_contact = FactoryGirl.attributes_for(:platform_contact)
      assert_difference 'PlatformContact.count' do
        post :contact_submit, platform_contact: platform_contact
      end
    end
  end
end
