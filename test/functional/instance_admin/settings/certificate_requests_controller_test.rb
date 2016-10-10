require 'test_helper'

class InstanceAdmin::Settings::CertificateRequestsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  should 'render new form' do
    get :new
    assert_response :success
    assert_template :new
  end

  should 'generate certificate' do
    zip = 'my_zip_file'
    NearMe::CertificateRequestGenerator.any_instance.stubs(:zip_file_stream).returns(zip)

    post :create, 'certificate_request' => {
      country: 'US',
      state: 'California',
      city: 'San Bernardino',
      organization: 'Rock the Bells',
      department: 'Music',
      common_name: 'www.rockthebells.test',
      email: 'odb@rockthebells.test'
    }
    assert_equal response.body, zip

    assert_equal response.header['Content-Type'], 'application/zip'
    assert_equal response.header['Content-Disposition'], "attachment; filename=\"www.rockthebells.test.zip\""
    assert_equal response.header['Content-Transfer-Encoding'], 'binary'
  end
end
