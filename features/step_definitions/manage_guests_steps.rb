Given /^#{capture_model} has second company with location "(.*)"$/ do |user_instance, location_name|
  user = model!(user_instance)
  company = FactoryGirl.create(:company, :creator => user)
  location = FactoryGirl.create(:location, :company => company, :address => location_name )
end

When(/^I reject reservation with reason$/) do
  click_on 'Decline'
  work_in_modal do
    fill_in 'reservation_rejection_reason', with: 'User has invalid details!'
    click_on 'submit-decline'
  end
end

