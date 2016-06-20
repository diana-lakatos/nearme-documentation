class InstanceAdmin::Settings::ResourceRecordsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    @domain = DomainDecorator.decorate PlatformContext.current.instance.default_domain
  end

  should 'raise error while incorrect data is sent' do
    resource = ResourceRecordForm.new({})
    resource.expects(process: false)

    @controller.stubs(:create_resource).returns(resource)

    post :create, domain_id: @domain.id, resource_record: {}
    assert_template :new
  end

  should 'create DNS record for hosted zone' do
    resource = ResourceRecordForm.new({})
    resource.expects(process: true)

    @controller.stubs(:create_resource).returns(resource)

    post :create, domain_id: @domain.id, resource_record: {}
    assert_response :redirect
  end
end
