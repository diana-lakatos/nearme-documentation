require Rails.root.join 'test/helpers/stub_helper'
include StubHelper

Given /^I am (host|guest) of a past reservation$/ do |kind|
  @reservation = FactoryGirl.create(:past_reservation)
  %w(transactable guest host).each { |subject| FactoryGirl.create(:rating_system, subject: subject, active: true, transactable_type: @reservation.listing.transactable_type) }
  @user = if kind == 'guest'
            @reservation.owner
          elsif kind == 'host'
            @reservation.creator
          end
  store_model('user', 'user', @user)

  instance = @reservation.instance
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

When(/^I submit rating with (valid|invalid) values$/) do |valid|
  RatingSystem.update_all(transactable_type_id: @reservation.listing.transactable_type_id)
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

When(/^I edit (host|transactable|guest) rating with (valid|invalid) values$/) do |object, valid|
  RatingSystem.update_all(transactable_type_id: @reservation.listing.transactable_type_id)
  rating_system = RatingSystem.where(subject: object).first
  rating_system ||= RatingSystem.where.not(subject: ['host', 'guest']).first
  FactoryGirl.create(:review, rating_system_id: rating_system.id, reviewable_id: @reservation.id, reviewable_type: @reservation.class.to_s, user: @user, rating: 5)

  visit dashboard_reviews_path(tab: 'completed')

  page.should have_css('.box.reviews .tab-pane.active')
  page.should have_css('.rating img')
  first('.review-actions .edit').click
  page.should have_css('.rating.editable')
  if valid == 'valid'
    first('.rating').first('img').click
  end
  click_button 'Submit Review'
  wait_for_ajax
end

When(/^I remove review$/) do
  RatingSystem.update_all(transactable_type_id: @reservation.listing.transactable_type_id)
  review = FactoryGirl.create(:review, rating_system_id: RatingSystem.for_hosts.first.id, reviewable_id: @reservation.id, reviewable_type: @reservation.class.to_s, user: @user, rating: 5)
  visit dashboard_reviews_path(tab: 'completed')
  page.driver.accept_js_confirms!

  page.should have_css('.box.reviews .tab-pane.active')
  first('.review-actions .remove').trigger(:click)
end

Then(/^I should see error message$/) do
  page.should have_css('span.rating-error')
  page.should_not have_css('.thanks')
end

Then(/^I should see success message and no errors$/) do
  page.should have_css('.thanks')
  page.should_not have_css('.rating .rating-error')
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
