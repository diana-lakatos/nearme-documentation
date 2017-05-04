module NewMarketplaceBuilder
  module SourceReaders
    class ZipReader
      def initialize(zip_file)
        @zip_file_path = zip_file
        @current_index = 0
      end

      def next
        full_file_path = files_in_mpbuilder_folder[@current_index]
        return cleanup_after_last_file unless full_file_path

        @current_index += 1
        { path: full_file_path.gsub(marketplace_folder_path, ''), content: File.read(full_file_path) }
      end

      private

      def files_in_mpbuilder_folder
        @files_in_mpbuilder_folder ||= begin
          save_file_to_tmp
          unzip_file
          select_all_builder_files_in_dir
        end
      end

      def save_file_to_tmp
        File.open("tmp/#{zip_file_name}.zip", 'wb') { |f| f.write(@zip_file_path.read) }
      end

      def unzip_file
        system "cd tmp; unzip #{zip_file_name}.zip -d #{zip_file_name} "
      end

      def select_all_builder_files_in_dir
        Dir.glob("#{marketplace_folder_path}/**/*").select do |path|
          File.file?(path) && /\.keep$/.match(path).nil?
        end
      end

      def cleanup_after_last_file
        FileUtils.rm_rf "tmp/#{zip_file_name}"
        nil
      end

      def marketplace_folder_path
        @path ||= "tmp/#{zip_file_name}"
      end

      def zip_file_name
        @zip_file_name ||= "instance-import-#{DateTime.now.to_i}"
      end
    end
  end
end
