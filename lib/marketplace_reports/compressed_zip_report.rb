# frozen_string_literal: true
module MarketplaceReports
  class CompressedZipReport
    def initialize(data, data_format)
      @data = data
      @data_format = data_format
    end

    def compress
      full_path_data = File.join(Rails.root, 'tmp', "#{temp_file_name}.#{@data_format}")
      full_path_zip = File.join(Rails.root, 'tmp', "#{temp_file_name}.zip")

      File.open(full_path_data, 'w') do |f|
        f.write(@data)
      end

      system("zip -j #{full_path_zip} #{full_path_data}")

      FileUtils.rm(full_path_data)

      full_path_zip
    end

    def temp_file_name
      @temp_file_name ||= "Report-#{Time.now.to_i}-#{rand(10_000_000)}"
    end
  end
end
