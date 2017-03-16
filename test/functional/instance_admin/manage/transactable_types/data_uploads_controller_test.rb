require 'test_helper'

class InstanceAdmin::Manage::TransactableTypes::DataUploadsControllerTest < ActionController::TestCase
  setup do
    @transactable_type = FactoryGirl.create(:transactable_type_csv_template)
    FactoryGirl.create(:location_type, name: 'My Type') unless LocationType.where(name: 'My Type').count > 0
    @user = FactoryGirl.create(:user)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'create' do
    should 'create new data upload with xml' do
      assert_difference 'DataUpload.count' do
        post :create, transactable_type_id: @transactable_type.id, data_upload: FactoryGirl.attributes_for(:data_upload)
      end
      @data_upload = assigns(:data_upload)
      @data_upload.reload
      assert_match(/\/instances\/#{PlatformContext.current.instance.id}\/uploads\/private\/data_upload\/xml_file/, @data_upload.xml_file.path)
    end
  end
end
