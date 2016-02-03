require 'test_helper'

class SingleLanguageRouterTest < ActionDispatch::IntegrationTest

  setup do
    Language::LanguageService.any_instance.stubs(:fallback_languages).returns([:en])
    Language::LanguageService.any_instance.stubs(:available_languages).returns([:en])
  end

  test 'does not redirect when there is no langauge param' do
    get root_path
    assert_response :success
  end

  test 'redirects when language param is set' do
    get root_path(language: 'de')
    assert_redirected_to '/'
  end

end
