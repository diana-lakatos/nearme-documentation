require 'test_helper'

class LocaleTest < ActiveSupport::TestCase
  should 'prevent deleting default locale' do
    default_locale = FactoryGirl.create(:default_locale, code: 'cs')
    refute default_locale.destroy
    assert_equal ["You can't delete default locale"], default_locale.errors[:base]
  end

  should 'reset other default locales' do
    default_locale = FactoryGirl.create(:default_locale)
    FactoryGirl.create(:default_locale, code: 'cs')
    default_locale.reload
    refute default_locale.primary?
  end

  should 'prevent deleting English locale' do
    locale = FactoryGirl.create(:locale)
    refute locale.destroy
    assert_equal ["You can't delete English locale"], locale.errors[:base]
  end
end
