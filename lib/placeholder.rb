class Placeholder

  IN_FILESYSTEM = ['96x96', '100x100', '144x89', '144x114', '279x279', '410x254', '895x554', '1280x960']

  def initialize(options = {})
    @height = options[:height]
    @width = options[:width]
    @format = "#{@width}x#{@height}"
  end

  def path
    if IN_FILESYSTEM.member?(@format)
      "placeholders/#{@format}.gif"
    else
      "//placehold.it/#{@format}&text=Photos+Unavailable"
    end
  end

end
