require 'test_helper'

class InstanceAdmin::Manage::WaiverAgreementTemplatesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @transactable_type = FactoryGirl.create(:transactable_type)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'index' do
    should 'display form for new waiver agreement template' do
      get :index
      assert :success
      assert_select 'form'
    end

    should 'be able to create new waiver agreement template' do
      assert_difference 'WaiverAgreementTemplate.count' do
        post :create, waiver_agreement_template: { content: 'This is content', name: 'My Name' }
      end
      wat = assigns(:waiver_agreement_template)
      assert_equal 'This is content', wat.content
      assert_equal 'My Name', wat.name
    end

    should 'create new waiver agreement template if one already exists in other instance' do
      FactoryGirl.create(:waiver_agreement_template, target: FactoryGirl.create(:instance))
      assert_difference 'WaiverAgreementTemplate.count' do
        post :create, waiver_agreement_template: { content: 'This is content', name: 'My Name' }
      end
    end

    should 'not create new waiver agreement template if one already exists' do
      FactoryGirl.create(:waiver_agreement_template)
      assert_no_difference 'WaiverAgreementTemplate.count' do
        post :create, waiver_agreement_template: { content: 'This is content', name: 'My Name' }
      end
    end
  end
end
