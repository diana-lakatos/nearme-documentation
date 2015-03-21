module PhotoHelpers
  def crop_photo(width, height)
    page.should have_css('.jcrop-tracker')
    page.execute_script("DNM.PhotoCrop.setSelect([0, 0, #{width}, #{height}]);")
  end

  def attach_file_via_uploader
    page.execute_script("$('input.browse-file').show().removeClass('hidden').css({width: 200, height: 50})")
    attach_file(find('.browse-file')[:name], File.join(Rails.root, 'test', 'assets', 'foobear.jpeg'))
    using_wait_time 5 do
      page.should_not have_css('.photo-item .loading-icon')
      page.should have_css('.photo-item img')
    end
  end
end

World(PhotoHelpers)
