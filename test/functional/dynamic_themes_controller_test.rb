# frozen_string_literal: true
require 'test_helper'

class DynamicThemesControllerTest < ActionController::TestCase
  setup do
    @theme = FactoryGirl.create(:theme)
  end

  should 'GET application.css' do
    get :show, theme_id: @theme, updated_at: @theme.updated_at.to_formatted_s(:number), stylesheet: 'application', format: :css
    assert :success
  end

  should 'GET dashboard.css' do
    get :show, theme_id: @theme, updated_at: @theme.updated_at.to_formatted_s(:number), stylesheet: 'dashboard', format: :css
    assert :success
  end

  should 'not GET wrong.css' do
    assert_raises ActionController::UrlGenerationError do
      get :show, theme_id: @theme, updated_at: @theme.updated_at.to_formatted_s(:number), stylesheet: 'wrong', format: :css
    end
  end
end
