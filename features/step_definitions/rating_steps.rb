require Rails.root.join 'test/helpers/stub_helper'
include StubHelper

Given /^I am (host|guest) of a past reservation$/ do |kind|
  @reservation = create_model('past_reservation')
  @user = if kind == 'guest'
            @reservation.owner
          elsif kind == 'host'
            @reservation.listing.location.creator
          end
  store_model('user', 'user', @user)
end

Given(/^I receive an email request for (host|guest) rating$/) do |kind|
  stub_local_time_to_return_hour(Location.any_instance, 12)

  RatingReminderJob.new(Date.current.to_s).perform

  assert_equal 2, ActionMailer::Base.deliveries.size
  @request_email = ActionMailer::Base.deliveries.detect { |e| e.to == [@user.email] }
  if kind=='host'
    assert_match /\[#{model!('instance').name}\] How was your experience at 'Listing \d+'/, @request_email.subject
  else
    assert_match /\[#{model!('instance').name}\] How was your experience hosting User-\d+/, @request_email.subject
  end
end

When(/^I submit a (host|guest) rating with comment and (good|bad) rating$/) do |kind, rating|
  work_in_modal do
    visit "/reservations/#{@reservation.id}/#{kind}_ratings/new"
    fill_in "#{kind}_rating_comment", with: Faker::Lorem.sentence
    click_button(rating.capitalize)
  end
end

Then(/^I should be redirected to mainpage$/) do
  page.should have_content('Thanks, your rating was submitted successfully!')
end

Then(/^guests rating should be recalculated$/) do
  @guest = @reservation.owner.reload
  assert_equal 1.0, @guest.guest_rating_average
  assert_equal 1, @guest.guest_rating_count
end

Then(/^hosts rating should be recalculated$/) do
  @host = @reservation.listing.location.creator.reload
  assert_equal 1.0, @host.host_rating_average
  assert_equal 1, @host.host_rating_count
end
