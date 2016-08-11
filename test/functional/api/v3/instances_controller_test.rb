# test InstanceFactory
require 'test_helper'

class Api::V3::InstancesControllerTest < ActionController::TestCase
  setup do
    FactoryGirl.create(:instance_admin_role_administrator) unless InstanceAdminRole.where(name: 'Administrator').count > 0

    ENV['APPLICATION_API_TOKEN'] = 'token'
    @request.headers['X-APPLICATION-API-TOKEN'] = 'token'
  end

  test 'search should raise when given invalid credentials' do
    post :create, instance_params.merge(format: 'json')
    assert_response :success

    assert JSON.parse(@response.body).keys.include?('data')
  end

  protected

  def instance_params
    {
      'instance_creator' => { 'email' => 'admin@near-me.com' },
      'user' => { 'name' => 'username' },
      'instance' => {
        'id' => 50_005,
        'name' => 'marketplace_name',
        'bookable_noun' => 'bookable_noun',
        'domains_attributes' => {
          '0' => { 'name' => 'domain.name' }
        },
        'theme_attributes' => { 'contact_email' => 'admin@near-me.com' }
      }
    }
  end
end
