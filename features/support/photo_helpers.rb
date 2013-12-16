module PhotoHelpers
  def crop_photo(width, height)
    page.should have_css('.jcrop-tracker')
    page.execute_script("DNM.PhotoCrop.setSelect([0, 0, #{width}, #{height}]);")
  end

  def attach_file_via_uploader
    page.execute_script "$('.browse-file').click()"
    page.should have_css('.photo-item .badge')
  end
end

World(PhotoHelpers)
