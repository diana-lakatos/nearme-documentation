class Placeholder
  IN_FILESYSTEM = %w(96x96 100x100 144x89 144x114 279x279 410x254 895x554 1280x960)

  def initialize(options = {}, text = nil)
    @height = options[:height]
    @width = options[:width]
    @format = "#{@width}x#{@height}"
    @text = text || I18n.t('placeholders.image_unavailable_or_still_processing')
  end

  def path
    # if IN_FILESYSTEM.member?(@format)
    #  "placeholders/#{@format}.gif"
    # else
    #  "//placehold.it/#{@format}&text=Photos+Unavailable"
    # end
    # Local filesystem placeholders do not work, we take all from placehold.it
    "//placehold.it/#{@format}&text=#{CGI.escape(@text)}"
  end
end
