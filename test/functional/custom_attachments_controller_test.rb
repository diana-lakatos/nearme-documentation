# frozen_string_literal: true
require 'test_helper'

class CustomAttachmentsControllerTest < ActionController::TestCase
  setup do
    @custom_attachment = FactoryGirl.create(:custom_attachment)
  end

  context 'with authorized user' do
    setup do
      sign_in FactoryGirl.create(:user)
    end

    should 'get file url' do
      get :show, id: @custom_attachment

      assert_redirected_to 'http://example.com/instances/1/uploads/attachments/custom_attachment/file/1/foobear.jpeg'
    end
  end

  context 'without authorized user' do
    should 'not see the attachment' do
      get :show, id: @custom_attachment

      assert_redirected_to root_url
    end
  end
end
