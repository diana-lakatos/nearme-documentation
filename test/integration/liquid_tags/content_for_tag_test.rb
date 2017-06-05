# frozen_string_literal: true
require 'test_helper'

class ContentForTagTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.new
  end

  context 'test with page' do
    setup do
      template = "
      Testing page
      {% content_for 'fragment_name_no_flush' %}
         First output no flush
      {% endcontent_for %}

      {% content_for 'fragment_name_no_flush' %}
         Second output no flush
      {% endcontent_for %}

      {% content_for 'fragment_name_flush' %}
         First output flush
      {% endcontent_for %}

      {% content_for 'fragment_name_flush', flush: true %}
         Second output flush
      {% endcontent_for %}
      "

      FactoryGirl.create(:instance_view_layout,
                         body: "
Layout header
= yield
= yield :fragment_name_no_flush
= yield :fragment_name_flush
                          ",
                         handler: 'haml')
      page = FactoryGirl.create(:page, path: 'test', slug: 'test')
      page.update_columns(layout_name: 'layouts/custom_layout', content: template, html_content: template)
    end

    should 'display' do
      get '/test'

      body = response.body
      assert_match(/First output no flush/, body)
      assert_match(/Second output no flush/, body)
      assert_no_match(/First output flush/, body)
      assert_match(/Second output flush/, body)
    end
  end
end
