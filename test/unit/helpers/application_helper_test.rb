require 'test_helper'
require 'action_view/test_case'

class ApplicationHelperTest < ActionView::TestCase

  test 'truncate with elipsis handles nil body' do
    assert_equal '', truncate_with_ellipsis(nil, 10)
  end

  test 'truncate with elipsis works' do
    assert_equal "<p><span class=\"truncated-ellipsis\">&hellip;</span><span class=\"truncated-text hidden\">0123456789 the rest should be truncated</span></p>", truncate_with_ellipsis("0123456789 the rest should be truncated", 10)
  end


  context 'with user associated to white label company' do

    setup do
      @company = FactoryGirl.create(:white_label_company)
      @user = FactoryGirl.create(:user, companies: [@company])
      @another_user = FactoryGirl.create(:user)
    end

    should 'allow that user_can_add_listing? when there is no white label white_label_company' do
      assert user_can_add_listing?
    end

    should 'not allow that user_can_add_listing? when user doesnt belong to white label company' do
      refute user_can_add_listing?(@company, @another_user)
    end

    should 'allow that user_can_add_listing? when user belongs to white label company' do
      assert user_can_add_listing?(@company, @user)
    end
  end

  context 'distance_of_time_in_words_or_date' do
    setup do
      @datetime = DateTime.new(2013, 1, 1, 12, 0, 0).in_time_zone
      Timecop.travel(@datetime)
    end

    should 'return hour and time' do
      assert_equal '10:00am', distance_of_time_in_words_or_date(@datetime - 2.hours)
    end

    should 'return Yesterday' do
      assert_equal 'Yesterday', distance_of_time_in_words_or_date(@datetime - 1.day)
    end

    should 'return week day' do
      assert_equal 'Friday', distance_of_time_in_words_or_date(@datetime - 4.days)
    end

    should 'return date' do
      assert_equal '2012-12-18', distance_of_time_in_words_or_date(@datetime - 14.days)
    end

    teardown do
      Timecop.return
    end

  end

end
