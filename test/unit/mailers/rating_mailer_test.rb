require 'test_helper'

class RatingMailerTest < ActiveSupport::TestCase
  setup do
    stub_mixpanel
    @user = FactoryGirl.create(:user)
    @reservation = FactoryGirl.create(:past_reservation, user: @user)
  end

  test '#request_rating_of_guest_from_host' do
    mail = RatingMailer.request_rating_of_guest_from_host(@reservation)

    assert_equal [@reservation.creator.email], mail.to
    assert_contains I18n.t('mailers.rating.experience_hosting', name: @reservation.owner.first_name), mail.subject
  end

  test '#request_rating_of_host_and_product_from_guest' do
    mail = RatingMailer.request_rating_of_host_and_product_from_guest(@reservation)

    assert_equal [@reservation.owner.email], mail.to
    assert_contains I18n.t('mailers.rating.experience_at', name: @reservation.listing.name), mail.subject
  end
end
