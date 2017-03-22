# frozen_string_literal: true
require 'test_helper'

class FormForTagTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.new
  end

  context 'with page' do
    setup do
      template = "
      {% form_for current_user, url: '/users' %}
         {% input email %}
      {% endform_for %}
      "
      FactoryGirl.create(:page, path: 'test', slug: 'test', content: template) # TODO: it should work with empty layout, layout_name: nil)
    end

    should 'display' do
      get '/test'

      assert_select 'form.simple_form'
      assert_select 'input[name="current_user[email]"]'
    end
  end
end
