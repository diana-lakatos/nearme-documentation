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
