# frozen_string_literal: true
require 'test_helper'

class ApiAuthorizationPoliciesTest < ActionDispatch::IntegrationTest

  setup do
    @user = FactoryGirl.create(:user, first_name: 'John', password: 'password')
    post_via_redirect '/users/sign_in', user: { email: @user.email, password: @user.password }
  end

  should 'allow to submit form if policies are met' do
    put_via_redirect "/api/users/#{@user.id}", { form: { first_name: 'Maciek' }, form_configuration_id: form_configuration_with_john_policy(form_configuration_a).id }
    assert_equal 'Maciek', @user.reload.first_name
    assert_response :success
  end

  should 'allow to submit form if there are no policies' do
    put_via_redirect "/api/users/#{@user.id}", { form: { first_name: 'Maciek' }, form_configuration_id: form_configuration_a.id }
    assert_equal 'Maciek', @user.reload.first_name
    assert_response :success
  end

  should 'not allow to submit form if policies are not met' do
    @user.update_attribute(:first_name, 'Jane')
    put_via_redirect "/api/users/#{@user.id}", { form: { first_name: 'Maciek' }, form_configuration_id: form_configuration_with_john_policy(form_configuration_a).id }
    assert_not_equal 'Maciek', @user.reload.first_name
    assert_response :forbidden
  end

  protected

  def form_configuration_a
    @form_configuration_a ||= FormConfiguration.create!(
      name: 'update_profile_a',
      base_form: 'UserForm',
      configuration: {
        first_name: {
          validation: { presence: {} }
        }
      }
    )
  end

  def form_configuration_with_john_policy(form_configuration)
    form_configuration.tap do |fc|
      fc.authorization_policies.create!(name: 'must_be_john',
                                        content: "{% if current_user.first_name == 'John'%}true{% endif %}")
    end
  end

  def form_configuration_b
    @form_configuration_a ||= FormConfiguration.create!(
      name: 'update_profile_b',
      base_form: 'UserForm',
      configuration: {
        last_name: {
          validation: { presence: {} }
        }
      }
    )
  end
end
