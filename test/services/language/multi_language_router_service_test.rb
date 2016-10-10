require 'test_helper'

class MultiLanguageRouterTest < ActionDispatch::IntegrationTest
  setup do
    Language::LanguageService.any_instance.stubs(:fallback_languages).returns([:de, :en])
    Language::LanguageService.any_instance.stubs(:available_languages).returns([:en, :de])
  end

  test 'does not redirect when select language is same as current language' do
    get root_path(language: 'en')
    assert_response :success
  end

  test 'redirects to first fallback langauge when there is no langauge param' do
    get root_path
    assert_redirected_to root_path(language: 'de')
  end

  test 'redirects to first fallback langauge when selected langauge is not supported' do
    get root_path(language: 'fr')
    assert_redirected_to root_path(language: 'de')
  end
end
