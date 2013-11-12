class Placeholder

  IN_FILESYSTEM = ['100x100', '410x254', '144x114', '895x554', '144x89', '279x279']

  def initialize(options = {})
    @height = options[:height]
    @width = options[:width]
    @format = "#{@width}x#{@height}"
  end

  def path
    if IN_FILESYSTEM.member?(@format)
      "placeholders/#{@format}.gif"
    else
      "http://placehold.it/#{@format}&text=Photos+Unavailable"
    end
  end

end
