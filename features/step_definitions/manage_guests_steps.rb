Given /^#{capture_model} has second company with location "(.*)"$/ do |user_instance, location_name|
  user = model!(user_instance)
  company = FactoryGirl.create(:company, :creator => user)
  location = FactoryGirl.create(:location, :company => company, :name => location_name )
end
