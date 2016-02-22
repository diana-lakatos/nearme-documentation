module PhotoHelpers
  def crop_photo(width, height)
    page.should have_css('.jcrop-tracker')
    page.execute_script("window.DNMPhotoCrop.setSelect([0, 0, #{width}, #{height}]);")
  end

  def attach_file_via_uploader
    page.execute_script("$('input.browse-file').css({display: 'block', visibility: 'visible', width: 200, height: 50}).removeClass('hidden')")
    attach_file(find('.browse-file')[:name], File.join(Rails.root, 'test', 'assets', 'foobear.jpeg'))
    wait_for_ajax
    page.should_not have_css('.photo-item .loading-icon')
    page.should have_css('.photo-item img')
  end
end

World(PhotoHelpers)
