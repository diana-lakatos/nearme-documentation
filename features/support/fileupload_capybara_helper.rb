module FileuploadCapybaraHelper
  def attach_hidden_file(name, image)
    make_input_visible(name)
    attach_file(name, image)
  end

  def make_input_visible(name)
    page.execute_script "$(\"input[name='#{name}']\").css('width', '10px')"
    page.execute_script "$(\"input[name='#{name}']\").css('height', '10px')"
  end
end
World(FileuploadCapybaraHelper)
