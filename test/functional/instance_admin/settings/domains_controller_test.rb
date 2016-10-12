require 'test_helper'
require 'nearme'

class InstanceAdmin::Settings::DomainsControllerTest < ActionController::TestCase
  context 'attributes' do
    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
      InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
      InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
      @domain = PlatformContext.current.instance.default_domain
    end

    should 'show list' do
      post :index
      assert_response :success
      assert_template :index
      assert_equal assigns[:domains], [@domain]
    end

    should 'new' do
      get :new
      assert_response :success
      assert_template :new
      assert_kind_of Domain, assigns[:domain]
      refute assigns[:domain].persisted?
    end

    context 'create' do
      should 'secured' do
        dns_name = 'test-dns-name.com'
        balancer = stub(dns_name: dns_name, create!: nil)
        NearMe::Balancer.expects(:new).returns(balancer)
        assert_difference('Domain.count') do
          post :create, domain: { 'name' => 'example.org', 'secured' => true, aws_certificate_id: FactoryGirl.create(:aws_certificate) }
          assert_equal flash[:success], I18n.t('flash_messages.instance_admin.settings.domain_preparing')
          assert_response :redirect
          assert_redirected_to instance_admin_settings_domains_path
        end
      end

      should 'unsecured' do
        assert_difference('Domain.count') do
          post :create, domain: { 'name' => 'example.org' }
          assert_equal flash[:success], I18n.t('flash_messages.instance_admin.settings.domain_created')
          assert_response :redirect
          assert_redirected_to instance_admin_settings_domains_path
        end
      end
    end
    should 'create' do
    end

    should 'update' do
      name = 'newname.com'
      put :update, id: @domain.id.to_s, domain: { 'name' => name }
      assert_response :redirect
      assert_redirected_to instance_admin_settings_domains_path
      assert_equal @domain.reload.name, name
    end

    should 'delete' do
      DeleteElbJob.expects(:perform)
      new_domain = FactoryGirl.create(:domain)
      assert_difference('Domain.count', -1) do
        delete :destroy, id: new_domain.id.to_s
        assert_response :redirect
        assert_redirected_to instance_admin_settings_domains_path
      end
    end
  end
end
