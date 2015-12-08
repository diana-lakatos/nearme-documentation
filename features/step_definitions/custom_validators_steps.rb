When /^custom validator exists for field (.*)$/ do |field_name|
  FactoryGirl.create(:custom_validator, field_name: field_name, validatable_type: 'Location')
end
