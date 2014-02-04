class ThemeFontUploader < BaseUploader

  def extension_white_list
    %w(ttf eot woff svg)
  end
end

