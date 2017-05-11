# frozen_string_literal: true
require 'test_helper'

module Api
  module V4
    module User
      class CustomImagesControllerTest < ActionController::TestCase
        setup do
          @user = FactoryGirl.create(:user)
          @custom_image = FactoryGirl.create(:custom_image, uploader: @user)
        end

        context 'with authorized user' do
          setup do
            sign_in @user
          end

          should 'destroy custom image' do
            assert_difference 'CustomImage.count', -1 do
              delete :destroy, id: @custom_image
            end
          end
        end

        context 'without authorized user' do
          setup do
            sign_in FactoryGirl.create(:user)
          end

          should 'not destroy custom image' do
            assert_raise ActiveRecord::RecordNotFound do
              assert_no_difference 'CustomImage.count' do
                delete :destroy, id: @custom_image
              end
            end
          end
        end
      end
    end
  end
end
