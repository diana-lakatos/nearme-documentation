require 'test_helper'

class InstanceAdmin::Settings::DocumentsUploadControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  context '#new' do
    should 'render new form' do
      get :new
      assert_response :success
      assert_template :new
    end
  end

  context '#edit' do
    setup do
      FactoryGirl.create(:documents_upload, instance: @user.instance)
    end

    should 'render edit form' do
      get :edit
      assert_response :success
      assert_template :edit
    end
  end

  context '#show' do
    should 'redirect to new action' do
      get :show
      assert_response :redirect
      assert_redirected_to new_instance_admin_settings_documents_upload_path
    end

    should 'redirect to edit action' do
      FactoryGirl.create(:documents_upload, instance: @user.instance)
      get :show
      assert_response :redirect
      assert_redirected_to edit_instance_admin_settings_documents_upload_path
    end
  end

  context '#create' do
    should 'redirect to edit action with success message' do
      post :create, documents_upload: FactoryGirl.attributes_for(:documents_upload, instance: @user.instance)
      assert_response :redirect
      assert_equal I18n.t('flash_messages.instance_admin.settings.settings_updated'), flash[:success]
      assert_redirected_to edit_instance_admin_settings_documents_upload_path
    end
  end

  context '#update' do
    setup do
      @documents_upload = FactoryGirl.create(:documents_upload, instance: @user.instance)
    end

    should 'redirect to edit action with success message' do
      put :update, documents_upload: { id: @documents_upload.id, requirement: DocumentsUpload::REQUIREMENTS.last }
      assert_response :redirect
      assert_equal I18n.t('flash_messages.instance_admin.settings.settings_updated'), flash[:success]
      assert_redirected_to edit_instance_admin_settings_documents_upload_path
    end

    should 'render edit form with error message' do
      put :update, documents_upload: { id: @documents_upload.id, requirement: '' }
      assert_template :edit
      assert_equal "Requirement can't be blank", flash[:error]
    end
  end
end
