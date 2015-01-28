require Rails.root.join 'test/helpers/stub_helper'
include StubHelper

Given /^I am (host|guest) of a past reservation$/ do |kind|
  @reservation = create_model('past_reservation')
  @user = if kind == 'guest'
            @reservation.owner
          elsif kind == 'host'
            @reservation.creator
          end
  store_model('user', 'user', @user)

  instance = @reservation.instance

  instance.transactable_types.each do |transactable_type|
    [instance.lessor, instance.lessee, instance.bookable_noun].each do |subject|
      rating_system = FactoryGirl.create(:rating_system, subject: subject, transactable_type_id: transactable_type.id, active: true)
      RatingConstants::VALID_VALUES.each { |value| FactoryGirl.create(:rating_hint, rating_system_id: rating_system.id, value: value) }
    end
  end
end

Given(/^I receive an email request for (host and listing|guest) rating$/) do |kind|
  stub_local_time_to_return_hour(Location.any_instance, 12)

  RatingReminderJob.perform(Date.current.to_s)

  assert_equal 2, ActionMailer::Base.deliveries.size
  @request_email = ActionMailer::Base.deliveries.detect { |e| e.to == [@user.email] }
  if kind=='host and listing'
    assert_match /\[#{model!('instance').name}\] How was your experience at 'Listing \d+'/, @request_email.subject
  else
    assert_match /\[#{model!('instance').name}\] How was your experience hosting User-\d+/, @request_email.subject
  end
end

When(/^I submit host rating with (valid|invalid) values$/) do |valid|
  visit dashboard_reviews_path
  page.should have_css('.box.reviews .tab-pane.active')
  page.should have_css('.rating img')

  if valid == 'valid'
    first('.rating').first('img').click
  else
    first('.show-details').click
  end

  click_button 'Submit Review'
end

When(/^I edit host rating with (valid|invalid) values$/) do |valid|
  FactoryGirl.create(:review, reservation: @reservation, user: @user, rating: 5)
  visit dashboard_reviews_path(tab: 'completed')

  page.should have_css('.box.reviews .tab-pane.active')
  page.should have_css('.rating img')
  first('.review-actions .edit').click
  page.should have_css('.rating.editable')

  if valid == 'valid'
    first('.rating').first('img').click
  end

  click_button 'Submit Review'
end

When(/^I remove review$/) do
  FactoryGirl.create(:review, reservation: @reservation, user: @user, rating: 5)
  visit dashboard_reviews_path(tab: 'completed')
  page.driver.accept_js_confirms!

  first('.review-actions .remove').trigger(:click)
end

Then(/^I should see error message$/) do
  page.should have_css('span.error')
  page.should_not have_css('.thanks')
end

Then(/^I should see success message and no errors$/) do
  page.should have_css('.thanks')
  page.should_not have_css('.rating .error')
end

Then(/^I should see updated feedback$/) do
  visit dashboard_reviews_path(tab: 'completed')
  page.should have_css('.box.reviews .tab-pane.active')
  page.should have_css('.rating img')
  page.should have_css('.rating.non-editable[data-score="1"]')
end

Then(/^I should see review in uncompleted feedback$/) do
  page.should have_css('.box.reviews .tab-pane.active')
  page.should have_css('.rating img')
  page.should have_css('#uncompleted-seller-feedback.active')
  page.should have_content(@reservation.listing.name)
end

