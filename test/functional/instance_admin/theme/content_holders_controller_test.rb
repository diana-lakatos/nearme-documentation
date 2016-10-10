require 'test_helper'

class InstanceAdmin::Theme::ContentHoldersControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  context 'Content Holder' do
    should 'be created' do
      assert_difference 'ContentHolder.count', 1 do
        post :create, content_holder: { name: 'HEAD', content: 'lorem ipsum head', enabled: true }
      end
      assert_redirected_to instance_admin_theme_content_holders_path
    end

    context 'object' do
      setup do
        @holder = FactoryGirl.create(:content_holder, name: 'Holder1')
      end

      should 'be edited' do
        put :update, id: @holder.id, content_holder: { enabled: false }
        assert_redirected_to instance_admin_theme_content_holders_path
        holder = ContentHolder.find @holder.id
        assert_equal holder.enabled, false
      end

      should 'be destroyed' do
        assert_difference 'ContentHolder.count', -1 do
          delete :destroy, id: @holder.id
        end
        assert_redirected_to instance_admin_theme_content_holders_path
      end
    end
  end
end
