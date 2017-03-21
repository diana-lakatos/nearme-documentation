  class CombinedImage
    include CarrierWave::MiniMagick

    def initialize(paths)
      @paths = paths
      @img = create_blank_image
      @file_path = @img.path
      combine
    end

    def file
      MiniMagick::Image.open(@file_path)
    end

    def combine
      @paths.each_with_index do |path, i|
        resource = MiniMagick::Image.open(path)
        @img.combine_options do |c|
          c.extent("#{[resource.width, @img.width].max}x#{[resource.height, @img.height].sum}")
        end
        @img = @img.composite(resource) { |c| c.gravity 'south' }
      end
      @img.write(@file_path)
    end

    def create_blank_image
      temp_file = Tempfile.new(['combined_tmp', '.jpg'])
      MiniMagick::Tool::Convert.new do |i|
        i.size "0x0"
        i.gravity "center"
        i.xc "white"
        i << temp_file.path
      end
      MiniMagick::Image.open(temp_file.path)
    end
end
