Then(/^I crop image$/) do
  work_in_modal do
    crop_photo(200, 125)
    click_on 'Process'
  end
end

When(/^I open rotate and crop modal$/) do
  within '.photo-item' do
    @image_width = Photo.last.image.width
    @image_height = Photo.last.image.height
    click_on 'Rotate & Crop'
  end
end

When(/^I should see cropped photo$/) do
  assert_equal 125, Photo.last.image.transformed.height
  assert_equal 200, Photo.last.image.transformed.width
end

Then(/^I rotate image$/) do
  work_in_modal do
    find('.rotate-photo').click
    click_on 'Process'
  end
end

When(/^I should see rotated photo$/) do
  Photo.last.image.transformed.should have_dimensions(@image_height, @image_width)
end
