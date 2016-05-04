class InstanceAdmin::Settings::HostedZonesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    @domain = PlatformContext.current.instance.default_domain
  end

  should 'create hosted zone' do
    SetupHostedZoneJob.expects(:perform).with(@domain.id)

    post :create, domain_id: @domain.id
    assert_response :redirect
  end
end
