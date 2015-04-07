# features/support/capybara_helper.rb
module CapybaraHelper
  # By default, capybara will ignore all hidden fields. This is a smart default
  # except in rare cases. For example, our AS3 file uploader requires you to
  # click a hidden file field - and that makes perfect sense. In those rare
  # cases, you can use this helper to override the default and force capybara
  # to include hidden fields.
  #
  # Examples
  #
  #   include_hidden_fields do
  #     attach_file("hidden-input", "path/to/fixture/file")
  #   end
  #
  def include_hidden_fields
    Capybara.ignore_hidden_elements = false
    yield
    Capybara.ignore_hidden_elements = true
  end
end
World(CapybaraHelper)