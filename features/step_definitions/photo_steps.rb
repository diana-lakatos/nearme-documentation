Then /^I should see (\d+) workplace photos?$/ do |count|
  all("ul#photos li img").should have(count.to_i).items
end

When /^I attach the photo "([^"]*)" to "([^"]*)"$/ do |photo, field|
  photo = File.join(Rails.root, *%w[features fixtures photos], photo)
  When %'I attach the file "#{photo}" to "#{field}"'
end

Then /^the workplace photos should be:$/ do |table|
  all("ul#photos li img").each do |image|
    table.raw.flatten.any? do |expected|
      expected.should =~ /#{image.attr("alt")}$/
    end
  end
end
