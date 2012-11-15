Then /^I should see (\d+) listing photos?$/ do |count|
  all(selector_for("photos")).should have(count.to_i).items
end

When /^I attach the photo "([^"]*)" to "([^"]*)"$/ do |photo, field|
  photo = File.join(Rails.root, *%w[features fixtures photos], photo)
  When %'I attach the file "#{photo}" to "#{field}"'
end

Then /^the listing photos should be:$/ do |table|
  all(selector_for("photos")).each do |image|
    table.raw.flatten.should include(image["alt"])
  end
end

When /^I add the following photos to the listing:$/ do |table|
  # FIXME: This isn't 'correct' (more than one listing will break the semantics)
  # We can fix it when we implement the new dashboard
  steps %{
    When I go to the dashboard
    And I follow "Manage Photos"
  }

  table.hashes.each_with_index do |row, count|
    attrs = row.except("File")

    attr_steps = attrs.map do |field_name, value|
      %(When I fill in "#{field_name}" with "#{value}")
    end.join("\n")

    steps %{
      When I attach the photo "#{row["File"]}" to "New Photo"
      #{attr_steps}
       And I press "Upload"
      Then I should see #{count + 1} listing photo
    }
  end
end

