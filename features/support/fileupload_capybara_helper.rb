module FileuploadCapybaraHelper
  def attach_hidden_file(name, image)
    make_input_visible(name)
    attach_file(name, image)
  end

  # I experienced weird bug issued at thoughtbot/capybara-webkit#494.
  # This is dirty fix how to set some dimensions to element.
  # Capybara sometimes can't click to zero dimensioned element.
  def make_input_visible(name)
    page.execute_script "$(\"input[name='#{name}']\").css('width', '10px')"
    page.execute_script "$(\"input[name='#{name}']\").css('height', '10px')"
  end
end

World(FileuploadCapybaraHelper)
