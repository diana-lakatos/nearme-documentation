Given /^I ask a question about a listing$/ do
  @listing = model('listing')
  visit listing_path(@listing.location, @listing)
  click_link 'Contact host'
  work_in_modal do
    fill_in 'listing_message_body', with: "Short one"
    click_button 'Send'
  end

  page.should have_content('Your message was sent!')
end

Then /^I should see this question in my inbox marked as read$/ do
  visit listing_messages_path
  page.should_not have_content('Messages (1)')
  page.should_not have_content('Inbox (1)')
  page.should have_content('Messages')
  page.should have_content('Inbox')
  page.should have_content model('user').first_name
  page.should have_content @listing.name
  page.should have_content 'Short one'
  page.find('.listing-message').should_not have_content('Read')
  page.find('.listing-message').should have_content('Archive')
end

When /^I log in as this listings creator$/ do
  log_out
  login @listing.creator
end

Then /^I should see this question in my inbox marked as unread$/ do
  visit listing_messages_path
  page.should have_content('Messages (1)')
  page.should have_content('Inbox (1)')
  page.should have_content model('user').first_name
  page.should have_content @listing.name
  page.should have_content 'Short one'
  page.find('.listing-message').should have_content('Read')
  page.find('.listing-message').should_not have_content('Archive')
end

Then /^I should be able to read, answer and archive this question$/ do
  click_link('Read')
  page.should have_content 'Short one'

  fill_in 'listing_message_body', with: 'This is answer'
  click_button('Send')
  page.should have_content('Your message was sent!')
  page.should_not have_content 'Short one'
  page.should have_content 'This is answer'

  click_link('Archive')
  page.should have_content('Your message was archived!')
  page.should_not have_content 'Short one'
  page.should_not have_content 'This is answer'

  click_link('Archived')
  page.should_not have_content 'Short one'
  page.should have_content 'This is answer'
end
