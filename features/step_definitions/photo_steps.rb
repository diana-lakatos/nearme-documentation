Then /^I should see (\d+) workplace photos?$/ do |count|
  all(selector_for("photos")).should have(count.to_i).items
end

When /^I attach the photo "([^"]*)" to "([^"]*)"$/ do |photo, field|
  photo = File.join(Rails.root, *%w[features fixtures photos], photo)
  When %'I attach the file "#{photo}" to "#{field}"'
end

Then /^the workplace photos should be:$/ do |table|
  all(selector_for("photos")).each do |image|
    table.raw.flatten.should include(image["alt"])
  end
end

When /^I add the following photos to the workplace:$/ do |table|
  steps %{
    When I go to the workplace's page
    And I follow "Manage Workplace Photos"
  }
  
  table.hashes.each_with_index do |row, count|
    steps %{
      When I attach the photo "#{row["File"]}" to "New Photo"
      When I fill in "Description" with "#{row["Description"]}"
       And I press "Upload"
      Then I should see #{count + 1} workplace photo
    }
  end
end

