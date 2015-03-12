require 'test_helper'

class InstanceAdmin::Theme::VersionsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  context "previous versions of page" do
    setup do
      with_versioning do
        @page = FactoryGirl.create(:page, path: 'Page test')
        @page.update content: "Lorem"
      end
    end

    should 'be listed' do
      get :index, parent_resource: "pages", page_id: @page.id
      assert_response :success
      assert_select '.versions tbody tr:first-child td:first-child', text: @page.versions.first.id
    end

    should "be viewable" do
      get :show, parent_resource: "pages", page_id: @page.id, id: @page.versions.last.id
      assert_response :success
      assert_not_equal @page.content, @page.versions.last.reify.content
      assert_select 'textarea', @page.versions.last.reify.content
    end

    should "be rollbackable" do
      last_version_id = @page.versions.last.id
      get :rollback, parent_resource: "pages", page_id: @page.id, id: last_version_id
      assert_redirected_to edit_instance_admin_theme_page_path(@page)
      assert_equal "Page has been successfully restored to previous version", flash[:notice]
      version = @page.versions.find last_version_id
      assert_equal @page.reload.content, version.reify.content
    end
  end

  context 'Previous versions of footer' do
    setup do
      with_versioning do
        @footer = FactoryGirl.create(:instance_view_footer, instance: Instance.first)
        @footer.update body: "Updated footer"
      end
    end

    should 'be listed' do
      get :index, parent_resource: "footer"
      assert_response :success
      assert_select '.versions tbody tr:first-child td:first-child', text: @footer.versions.first.id
    end

    should "be viewble" do
      get :show, parent_resource: "footer", id: @footer.versions.last.id
      assert_response :success
      assert_not_equal @footer.body, @footer.versions.last.reify.body
      assert_select 'textarea', @footer.versions.last.reify.body
    end

    should "be rollbackable" do
      last_version_id = @footer.versions.last.id
      get :rollback, parent_resource: "footer", id: last_version_id
      assert_redirected_to instance_admin_theme_footer_path
      assert_equal "Page has been successfully restored to previous version", flash[:notice]
      version = @footer.versions.find last_version_id
      assert_equal @footer.reload.body, version.reify.body
    end

  end
end

