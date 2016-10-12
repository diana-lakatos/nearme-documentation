class DataImporter::File
  attr_accessor :path

  def initialize(path)
    if File.readable?(path) || (path.to_s =~ /^http/)
      @path = path
    else
      fail "Not readable file path: #{path} and not url"
    end
  end
end
