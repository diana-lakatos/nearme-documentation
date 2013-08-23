module PhotoHelpers
  def crop_photo(width, height)
    page.should have_css('.jcrop-tracker')
    page.execute_script("DNM.PhotoCrop.setSelect([0, 0, #{width}, #{height}]);")
  end
end

World(PhotoHelpers)
