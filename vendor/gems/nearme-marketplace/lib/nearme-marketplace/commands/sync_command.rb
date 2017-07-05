module NearmeMarketplace
  class SyncCommand < BaseCommand
    def execute!
      puts "Sync mode enabled!".green

      listener = Listen.to('marketplace_builder/') do |modified, added, removed|
        changed_file_paths = added + modified

        changed_file_paths.each do |changed_file_path|
          begin
            on_file_changed(changed_file_path)
          rescue
            puts_status "Sync failed. Fix a file! #{changed_file_path}"
          end
        end
      end

      listener.start
      sleep
    end

    private

    def on_file_changed(changed_file_path)
      puts "Updating: #{changed_file_path}"

      File.open(changed_file_path, 'rb') do |changed_file|
        response = connection.put("api/marketplace_releases/sync", request_params(changed_file))
        handle_server_response(response)
      end
    end

    def request_params(file)
      {
        path: file.path.gsub("#{Dir.getwd}/marketplace_builder/", ""),
        marketplace_builder_file_body: file.read
      }
    end
  end
end
