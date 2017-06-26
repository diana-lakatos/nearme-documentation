# frozen_string_literal: true
require 'test_helper'

class PagePoliciesTest < ActionDispatch::IntegrationTest
  setup do
    @user = FactoryGirl.create(:user, first_name: 'John', password: 'password')
    @page = FactoryGirl.create(:page, content: '<h1>My page</h1>')
    post_via_redirect '/users/sign_in', user: { email: @user.email, password: @user.password }
  end

  should 'allow to submit form if policies are met' do
    @page.authorization_policies.create!(name: 'must_be_john',
                                         content: "{% if current_user.first_name == 'John'%}true{% endif %}")
    get page_slug
    assert_response :success
    assert_select 'h1', 'My page'
  end

  should 'allow to submit form if there are no policies' do
    get page_slug
    assert_response :success
    assert_select 'h1', 'My page'
  end

  should 'not allow to submit form if policies are not met' do
    @page.authorization_policies.create!(name: 'must_be_jane',
                                         content: "{% if current_user.first_name == 'Jane'%}true{% endif %}")
    get page_slug
    assert_response :forbidden
  end

  protected

  def page_slug
    "/#{@page.slug}"
  end
end
