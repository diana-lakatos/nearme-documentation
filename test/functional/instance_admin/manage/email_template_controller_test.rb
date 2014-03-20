require 'test_helper'

class InstanceAdmin::Manage::EmailTemplatesControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  context 'new action' do
    should 'redirect to index if given a non-whitelisted path' do
      get :new, :path => 'invalid/pathname'
      assert flash[:error].include?(I18n.t('flash_messages.instance_admin.manage.email_templates.invalid'))
      assert_redirected_to instance_admin_manage_email_templates_url
    end

    should 'return a email template from the chosen path and render the new form' do
      get :new, :path => 'post_action_mailer/sign_up_welcome'
      assert assigns(:email_template).present?
      assert_template :new
    end
  end

  context 'create' do
    should 'not create email template with invalid path' do
      post :create, email_template: { path: 'invalid/path',
                                      text_body: "text body",
                                      html_body: "<p>html body</p>" }

      assert flash[:error].include?("not included in the list")
      assert_template :new
    end

    should 'create email template with valid path and params' do
      assert_difference 'EmailTemplate.count' do
        post :create, email_template: { path: 'post_action_mailer/sign_up_welcome',
                                        text_body: "text body",
                                        html_body: "<p>html body</p>" }
      end

      assert flash[:success].include?(I18n.t('flash_messages.instance_admin.manage.email_templates.created'))
      assert_redirected_to instance_admin_manage_email_templates_url
    end
  end
end
