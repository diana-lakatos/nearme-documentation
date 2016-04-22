Given /^UserMessage alerts exist$/ do
  Utils::DefaultAlertsCreator::UserMessageCreator.new.create_all!
end

Given /^I ask a question about a transactable$/ do
  @listing = model('transactable')
  @user = model('user')
  visit @listing.decorate.show_path
  click_link "Contact"
  work_in_modal do
    fill_in 'user_message_body', with: "Short one"
    click_button 'Send'
  end

  page.should have_content('Your message was sent!')
end

Then /^I should see this question in my inbox marked as read$/ do
  visit dashboard_user_messages_path
  page.should_not have_css('.count')
  page.should_not have_content('Inbox (1)')
  page.should have_content('Messages')
  page.should have_content('Inbox')
  page.should have_content model('user').first_name
  page.should have_content @listing.name
  page.should have_content 'Short one'
  page.find('.message').should have_content('Archive')
end

When /^I log in as this listings creator$/ do
  log_out
  login @listing.creator
end

Then /^I should see this question in my inbox marked as unread$/ do
  visit dashboard_user_messages_path
  find('.count').should have_content('1')
  page.should have_content('Inbox (1)')
  page.should have_content model('user').first_name
  page.should have_content @listing.name
  page.should have_content 'Short one'
  page.find('.message').should have_content('Archive')
end

Then /^I should be able to read, answer and archive this question$/ do
  click_link('Read')
  page.should have_content 'Short one'

  fill_in 'user_message_body', with: 'This is answer'
  click_button('Send')
  page.should have_content('Your message was sent!')
  page.should have_content 'Short one'
  page.should have_content 'This is answer'
  visit dashboard_user_messages_path

  click_link('Archive')
  page.should have_content('Your message was archived!')
  page.should_not have_content 'Short one'
  page.should_not have_content 'This is answer'


  within('select.messages') do
    select 'Archived'
  end
  page.should_not have_content 'Short one'
  page.should have_content 'This is answer'
end

Then /^this listings creator should get email with notification$/ do
  last_email_for(@listing.creator.email).subject.should include "You received a message!"
end

Then /^question owner should get email with notification$/ do
  last_email_for(@user.email).subject.should include "You received a message!"
end

Given /^I send a message to another user on his profile page$/ do
  @user = model('user')
  @another_user = FactoryGirl.create(:user)
  visit profile_path(@another_user)
  find('header.user-profile__header').find("[rel='modal']").click
  work_in_modal do
    fill_in 'user_message_body', with: "Short one"
    click_button 'Send'
  end

  page.should have_content('Your message was sent!')
end

Then /^I should see this( reservation)? message in my inbox marked as read$/ do |reservation_message|
  visit dashboard_user_messages_path

  page.should have_no_selector(:xpath, "//a[@href='/dashboard/user_messages']/span[@class='count']")
  page.should_not have_content('Inbox (1)')
  page.should have_content('Messages')
  page.should have_content('Inbox')
  if reservation_message
    page.should have_content @reservation.listing.administrator.first_name
    page.should have_content @reservation.name
  else
    page.should have_content model('user').first_name
    page.should have_content @another_user.name
  end
  page.should have_content 'Short one'
  page.find('.message').should have_content('Archive')
end

When /^I log in as this user$/ do
  log_out
  login @another_user
end

Then /^I should see this( reservation)? message in my inbox marked as unread$/ do |reservation_message|
  visit dashboard_user_messages_path
  page.should have_xpath("//a[@href='/dashboard/user_messages']/span[@class='count']", text: 1)

  page.should have_content('Inbox (1)')
  if reservation_message
    page.should have_content @reservation.listing.administrator.first_name
    page.should have_content @reservation.name
  else
    page.should have_content model('user').first_name
    page.should have_content @another_user.name
  end
  page.should have_content 'Short one'
  page.find('.message').should have_content('Archive')
end

Given /^I am logged in as the reservation administrator$/ do
  @reservation = model('reservation')
  login @reservation.listing.administrator
end

Given /^I send a message to reservation owner$/ do
  page.execute_script("$('.order a.ico-mail').click()")
  work_in_modal do
    fill_in 'user_message_body', with: "Short one"
    click_button 'Send'
  end

  page.should have_content('Your message was sent!')
end

Given /^I am logged in as the reservation owner/ do
  log_out
  login @reservation.owner
end
