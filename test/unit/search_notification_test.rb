require 'test_helper'

class SearchNotificationTest < ActiveSupport::TestCase
  context '#email' do
    should 'return user email if user set' do
      @search_notification = create :search_notification, :with_user
      assert @search_notification.email, @search_notification.user.email
    end

    should 'return model email if anonymous' do
      @search_notification = create :search_notification, email: 'notifyme@test.com'
      assert @search_notification.email, 'notifyme@test.com'
    end
  end

  context 'validations' do
    context 'email' do
      context 'anonymous' do
        subject { FactoryGirl.build :search_notification }
        should_not allow_value('').for(:email)
        should_not allow_value('123').for(:email)
        should allow_value('test@test.com').for(:email)
      end

      context 'with user' do
        subject { FactoryGirl.build :search_notification, :with_user }
        should allow_value('').for(:email)
      end
    end
  end
end
