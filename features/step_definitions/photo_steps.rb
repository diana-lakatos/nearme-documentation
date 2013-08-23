Then /^I should see (\d+) listing photos?$/ do |count|
  all(selector_for("photos")).should have(count.to_i).items
end

When /^I attach the photo "([^"]*)" to "([^"]*)"$/ do |photo, field|
  photo = File.join(Rails.root, *%w[features fixtures photos], photo)
  step %'I attach the file "#{photo}" to "#{field}"'
end

Then /^the listing photos should be:$/ do |table|
  all(selector_for("photos")).each do |image|
    table.raw.flatten.should include(image["alt"])
  end
end

When /^I add the following photos to the listing:$/ do |table|
  # FIXME: This isn't 'correct' (more than one listing will break the semantics)
  # We can fix it when we implement the new dashboard
  step "I go to the manage locations page"
  step "I follow \"Locations\""
  step "I follow \"Edit\""
  step "I follow \"Listings\""
  step "I follow \"Edit\""
  step "I follow \"Photos\""

  table.hashes.each_with_index do |row, count|
    attrs = row.except("File")

    attr_steps = attrs.map do |field_name, value|
      %(I fill in "#{field_name}" with "#{value}")
    end.join("\n")

    step "I attach the photo \"#{row["File"]}\" to \"New Photo\""
    step attr_steps
    step "I press \"Upload\""
    step "I should see #{count + 1} listing photo"
  end
end

Then(/^I crop image$/) do
  work_in_modal do
    crop_photo(200, 125)
    click_on 'Process'
  end
end

When(/^I open rotate and crop modal$/) do
  within '.photo-item' do
    @image_src = page.find('img')['src']
    @image_width = Photo.last.image.width
    @image_height = Photo.last.image.height
    click_on 'Rotate & Crop'
  end
end

When(/^I should see cropped photo$/) do
  page.find('img')['src'].should_not == @image_src
  Photo.last.image.adjusted.should have_dimensions(200, 125)
end

Then(/^I rotate image$/) do
  work_in_modal do
    find('.rotate-photo').click
    click_on 'Process'
  end
end

When(/^I should see rotated photo$/) do
  page.find('img')['src'].should_not == @image_src
  Photo.last.image.adjusted.should have_dimensions(@image_height, @image_width)
end
