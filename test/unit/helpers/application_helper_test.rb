require 'test_helper'
require 'action_view/test_case'

class ApplicationHelperTest < ActionView::TestCase
  include Devise::TestHelpers

  context 'distance_of_time_in_words_or_date' do
    setup do
      @datetime = DateTime.new(2013, 1, 1, 12, 0, 0).in_time_zone
      travel_to(@datetime)
    end

    should 'return hour and time' do
      assert_equal '10:00', distance_of_time_in_words_or_date(@datetime - 2.hours)
    end

    should 'return Yesterday' do
      assert_equal 'Yesterday', distance_of_time_in_words_or_date(@datetime - 1.day)
    end

    should 'return week day' do
      assert_equal '12/28/2012', distance_of_time_in_words_or_date(@datetime - 4.days)
    end

    should 'return date' do
      assert_equal '12/18/2012', distance_of_time_in_words_or_date(@datetime - 14.days)
    end

    teardown do
      travel_back
    end
  end

  context '#mask_phone_and_email_if_necessary' do
    should 'return text if current instance does not want to hide' do
      assert_equal 'this is dev@near-me.com my email', mask_phone_and_email_if_necessary('this is dev@near-me.com my email')
    end

    context 'instance does want to hide emails and phones' do
      setup do
        PlatformContext.current = PlatformContext.new(FactoryGirl.create(:instance, apply_text_filters: true))
        FactoryGirl.create(:text_filter_email)
        FactoryGirl.create(:text_filter_10phone)
        FactoryGirl.create(:text_filter_7phone)
      end

      should 'replace phones and emails' do
        assert_equal 'try my [EMAIL FILTERED] call me [10PHONE FILTERED] or other [EMAIL FILTERED] emails also call [7PHONE FILTERED]', mask_phone_and_email_if_necessary('try my aBc@ExaMplE.cOm call me 555.555.5555 or other dev@near-me.com emails also call 8456950')
      end

      should 'do not replace random numbers' do
        assert_equal "it's 100% safe, only 299 usd", mask_phone_and_email_if_necessary("it's 100% safe, only 299 usd")
      end
    end
  end
end
