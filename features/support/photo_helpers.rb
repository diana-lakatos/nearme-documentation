module PhotoHelpers
  def crop_photo(width, height)
    page.should have_css('.jcrop-tracker')
    page.execute_script("window.DNMPhotoCrop.setSelect([0, 0, #{width}, #{height}]);")
  end

  def attach_file_via_uploader
    page.execute_script("$('input[data-image-input]').css({display: 'block', visibility: 'visible', width: 200, height: 50}).removeClass('hidden')")
    attach_file find('input[data-image-input]')[:name], File.join(Rails.root, 'test', 'assets', 'foobear.jpeg')
    wait_for_ajax
    page.should have_css('[data-photo-item] img')
  end
end

World(PhotoHelpers)
