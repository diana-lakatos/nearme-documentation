class DataImporter::File

    def initialize(path)
      if File.readable?(path)
        @path = path
      else
        raise "Not readable file path: #{path}"
      end
    end

end
