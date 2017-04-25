module NewMarketplaceBuilder
  module SourceReaders
    class PathReader
      def initialize(source_path)
        @source_path = source_path
        @current_index = 0
      end

      def next
        full_file_path = files_in_mpbuilder_folder[@current_index]
        return nil unless full_file_path

        @current_index += 1
        { path: full_file_path.gsub(@source_path, ''), content: File.read(full_file_path) }
      end

      private

      def files_in_mpbuilder_folder
        @files_in_mpbuilder_folder ||= Dir.glob("#{@source_path}/**/*").select do |path|
          File.file?(path) && /\.keep$/.match(path).nil?
        end
      end
    end
  end
end
