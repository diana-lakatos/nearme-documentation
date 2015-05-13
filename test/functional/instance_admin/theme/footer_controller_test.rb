require 'test_helper'

class InstanceAdmin::Theme::FooterControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  context 'Previous versions of footer' do
    setup do
      with_versioning do
        @footer = FactoryGirl.create(:instance_view_footer, instance: Instance.first)
        @footer.update body: "Updated footer"
      end
    end

    should 'be listed' do
      get :versions, parent_resource: "footer"
      assert_response :success
      assert_select 'table tbody tr:last-child td:first-child', text: @footer.versions.first.id
    end

    should "be viewble" do
      get :show_version, version_id: @footer.versions.last.id
      assert_response :success
      assert_not_equal @footer.body, @footer.versions.last.reify.body
      assert_select 'textarea', @footer.versions.last.reify.body
    end

    should "be rollbackable" do
      last_version_id = @footer.versions.last.id
      get :rollback, version_id: last_version_id
      assert_redirected_to instance_admin_theme_footer_path(id: @footer.id)
      assert_equal "Page has been successfully restored to previous version", flash[:notice]
      version = @footer.versions.find last_version_id
      assert_equal @footer.reload.body, version.reify.body
    end

  end
end
