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
  time = mock()
  time.expects(:hour).returns(12)
  Location.any_instance.stubs(:local_time).returns(time)
  RatingReminderJob.new(Date.today.to_s).perform
  assert_equal 2, ActionMailer::Base.deliveries.size
  @request_email = ActionMailer::Base.deliveries.detect { |e| e.to == [@user.email] }
  assert_match /\[DesksNearMe\] Rate your #{kind} at Listing \d+/, @request_email.subject
end

When(/^I submit a (host|guest) rating with thumb up and a comment$/) do |kind|
  visit "/reservations/#{@reservation.id}/#{kind}_ratings/new"
  find('#thumbs-up').click
  fill_in 'Comment', with: Faker::Lorem.sentence
  click_button('Submit rating')
end

Then(/^I should be redirected to mainpage$/) do
  page.should have_content('Rating was successfully stored. Thank you for sharing!')
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
