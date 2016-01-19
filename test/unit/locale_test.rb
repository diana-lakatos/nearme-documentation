require 'test_helper'

class LocaleTest < ActiveSupport::TestCase
  should 'prevent deleting default locale' do
    primary_locale = Locale.first
    refute primary_locale.destroy
    assert_equal ["You can't delete default locale"], primary_locale.errors[:base]
  end

  should 'reset other default locales' do
    default_locale = Locale.first
    FactoryGirl.create(:primary_locale, code: 'cs')
    default_locale.reload
    refute default_locale.primary?
  end

  should 'delete all instance keys for locale' do
    locale = FactoryGirl.create(:locale, code: 'cs')
    FactoryGirl.create(:czech_translation, instance_id: 1)
    locale.destroy
    assert_equal 0, Translation.where(locale: locale.code).count
  end

  should 'set proper user language when deleted' do
    locale = FactoryGirl.create(:locale, code: 'cs')
    FactoryGirl.create(:user, language: 'cs')

    assert_difference 'User.where(language: "cs").count', -1 do
      assert locale.destroy
    end
  end
end
