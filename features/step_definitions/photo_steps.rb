Then(/^I crop image$/) do
  work_in_modal do
    crop_photo(200, 125)
    click_on 'Process'
  end
end

When(/^I open rotate and crop modal$/) do
  @photo = Photo.last
  @photo.image_original_width = MiniMagick::Image.open(Photo.last.image.current_path)[:width]
  @photo.image_original_height = MiniMagick::Image.open(Photo.last.image.current_path)[:height]
  @photo.save!
  within '.photo-item' do
    click_on 'Rotate & Crop'
  end
end

When(/^I should see cropped photo$/) do
  assert_equal 200, MiniMagick::Image.open(Photo.last.image.transformed.current_path)[:width]
  assert_equal 125, MiniMagick::Image.open(Photo.last.image.transformed.current_path)[:height]
end

Then(/^I rotate image$/) do
  work_in_modal do
    find('.rotate-photo').click
    click_on 'Process'
  end
end

When(/^I should see rotated photo$/) do
  assert_equal @photo.image_original_height, MiniMagick::Image.open(Photo.last.image.transformed.current_path)[:width]
  assert_equal @photo.image_original_width, MiniMagick::Image.open(Photo.last.image.transformed.current_path)[:height]
end
