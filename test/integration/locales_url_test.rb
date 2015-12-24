require 'test_helper'

class LocalesUrlTest < ActionDispatch::IntegrationTest

  setup do
    I18n.locale = :en
    RoutingFilter.active = true
    @primary_locale = FactoryGirl.create(:primary_locale, code: 'en')
  end

  should 'redirect to default language if locale does not exist' do
    get 'http://www.example.com/it/'
    assert_redirected_to 'http://www.example.com/'
  end

  should 'redirect to path without locale for default locale' do
    @primary_locale.update_attribute(:primary, false)
    FactoryGirl.create(:primary_locale, code: 'aa')
    PlatformContext.current.instance.reload
    get 'http://www.example.com/aa/'
    assert_redirected_to 'http://www.example.com/'
  end

  should 'not redirect for existing locale' do
    FactoryGirl.create(:locale, code: 'fr')
    get 'http://www.example.com/fr/'
    assert_response :success
  end

  should 'throw exception for fantasy locale' do
    assert_raises ActionController::RoutingError do
      get root_path(language: 'xy')
    end
  end

  should 'give url locale higher preference than user locale' do
    Locale.destroy_all
    FactoryGirl.create(:locale, code: 'de')
    FactoryGirl.create(:locale, code: 'cs')
    Utils::EnLocalesSeeder.new.go!
    user = FactoryGirl.create(:user, language: 'cs')
    get 'http://www.example.com/'
    assert_response :success
    assert :en, I18n.locale

    post_via_redirect user_session_path, 'user[email]' => user.email, 'user[password]' => user.password
    assert_equal 'Signed in successfully.', flash[:notice]

    get 'http://www.example.com/de'
    assert_response :success
    assert :de, I18n.locale
  end

  teardown do
    RoutingFilter.active = false
    I18n.locale = :en
  end
end
