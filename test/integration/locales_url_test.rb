require 'test_helper'

class LocalesUrlTest < ActionDispatch::IntegrationTest

  setup do
    RoutingFilter.active = true
    FactoryGirl.create(:primary_locale, code: 'en')
  end

  should 'redirect to default language if locale does not exist' do
    get 'http://www.example.com/it/'
    assert_redirected_to 'http://www.example.com/'
  end

  should 'redirect to path without locale for default locale' do
    FactoryGirl.create(:primary_locale, code: 'aa')
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

  should 'set locale based on user preference' do
    FactoryGirl.create(:locale, code: 'cs')
    user = FactoryGirl.create(:user, language: 'cs')

    get 'http://www.example.com/'
    assert_response :success
    assert :en, I18n.locale

    stub_mixpanel
    post_via_redirect 'users/sign_in', 'user[email]' => user.email, 'user[password]' => user.password
    assert_equal 'Signed in successfully.', flash[:notice]

    get 'http://www.example.com/hy/'
    assert_redirected_to 'http://www.example.com/cs'
    assert :cs, I18n.locale
  end
end
