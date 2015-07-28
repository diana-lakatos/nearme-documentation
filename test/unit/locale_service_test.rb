require 'test_helper'

class LocaleServiceTest < ActiveSupport::TestCase

  def setup
    @instance = Instance.first
    @instance.locales << FactoryGirl.create(:primary_locale)
    @instance.locales << FactoryGirl.create(:locale, code: 'cs')
    @instance.locales << FactoryGirl.create(:locale, code: 'fr')
    @instance.reload
    PlatformContext.current.instance.reload
  end

  should 'not return redirect URL for no locale given' do
    locale_service = LocaleService.new @instance, nil, nil, '/'
    refute locale_service.redirect?
    assert_nil locale_service.redirect_url
    assert_equal :en, locale_service.locale
  end

  should 'return redirect URL when locale does not exist on instance' do
    locale_service = LocaleService.new @instance, 'it', nil, '/it'
    assert locale_service.redirect?
    assert_equal '/', locale_service.redirect_url
    assert_equal @instance.primary_locale, locale_service.locale
  end

  should 'return redirect URL when requested locale is same as primary locale and no user locale' do
    locale_service = LocaleService.new @instance, 'en', nil, '/en'
    assert locale_service.redirect?
    assert_equal '/', locale_service.redirect_url
    assert_equal @instance.primary_locale, locale_service.locale
  end

  should 'not return redirect URL when requested locale is same as primary locale and user locale present' do
    locale_service = LocaleService.new @instance, 'en', 'cs', '/en'
    refute locale_service.redirect?
    assert_nil locale_service.redirect_url
    assert_equal :en, @instance.primary_locale
    assert_equal :en, locale_service.locale
  end

  should "give url locale higher precedence than user locale" do
    locale_service = LocaleService.new @instance, 'fr', 'cs', '/'
    refute locale_service.redirect?
    assert_nil locale_service.redirect_url
    assert_equal :fr, locale_service.locale
  end

  should "not return redirect URL when user's language is same as requested locale" do
    locale_service = LocaleService.new @instance, 'cs', 'cs', '/cs'
    refute locale_service.redirect?
    assert_nil locale_service.redirect_url
    assert_equal :cs, locale_service.locale
  end
end
