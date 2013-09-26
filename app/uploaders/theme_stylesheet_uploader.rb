class ThemeStylesheetUploader < BaseUploader
  # TODO: Add propper caching headers to uploaded file

  def extension_white_list
    %w(css)
  end
end

