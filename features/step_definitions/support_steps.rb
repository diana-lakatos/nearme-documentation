Given /^Alerts for support exist$/ do
  Utils::DefaultAlertsCreator::SupportCreator.new.create_all!
end

Given(/^a support admin$/) do
  @instance = Instance.first
  @role = FactoryGirl.create(:instance_admin_role_administrator, instance_id: @instance.id)
  @user = FactoryGirl.create(:user)
  @instance_admin = FactoryGirl.create(:instance_admin, :user_id => @user.id, :instance_id => @instance.id)
  @instance_admin.update_attribute(:instance_owner, true)
  @instance_admin.update_attribute(:instance_admin_role_id, @role.id)
end

Given(/^I open a support ticket$/) do
  visit support_root_path
  click_link 'Open a Ticket'
  fill_in "Subject", with: "My first support ticket"
  fill_in "Message", with: "Yet another ticket message"
  click_button "Create ticket"
end

Given(/^I open a guest support ticket$/) do
  visit support_root_path
  click_link 'Open a Ticket'
  fill_in "Full name", with: "Jimmy Banana"
  fill_in "Email", with: "jimmy@banana.eu"
  fill_in "Subject", with: "My first support ticket"
  fill_in "Message", with: "Yet another ticket message"
  click_button "Create ticket"
end

Then(/^I have one opened ticket$/) do
  user = Support::Ticket.first.user
  assert_equal 1, user.tickets.count
  assert_equal 1, user.tickets.for_filter('open').count
end

Then(/^I receive request received email$/) do
  assert_equal 2, ActionMailer::Base.deliveries.count
end

Then(/^support admin has one opened ticket$/) do
  assert_equal 1, Instance.first.tickets.for_filter('open').count
end

Then(/^support admin receives support received email$/) do
  assert_equal 2, ActionMailer::Base.deliveries.count
end

Then(/^I should see this support ticket$/) do
  InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
  InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  visit instance_admin_support_root_path
  page.should have_content('View and resolve')
end

Then(/^I should be able to answer and marked as resolved this support ticket$/) do
  InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
  InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  user = Support::Ticket.first.try(:user)
  visit instance_admin_support_root_path
  click_link 'View and resolve'
  fill_in 'Message', with: 'That is ok.'
  click_button 'Update and Resolve'
  assert_equal 1, Instance.first.tickets.for_filter('resolved').count
  assert_equal 1, user.tickets.for_filter('resolved').count if user
  assert_equal 2, Support::TicketMessage.count
end

Then(/^I log in support admin$/) do
  login @user
end

Then(/^support ticked owner should get email with notification$/) do
  assert_equal 3, ActionMailer::Base.deliveries.count
end
