module NearmeMarketplace
  class DeployCommand < BaseCommand
    def execute!
      puts "Deploy command started!".green

      zip_marketplace_builder_directory
      response = send_zip_to_server
      handle_server_response(response)
      wait_for_finish_job(response)
      remove_zip_file
    end

    private

    def zip_marketplace_builder_directory
      puts "Compressing marketplace_builder folder".green
      system "cd marketplace_builder; zip -r marketplace_builder.zip ."
    end

    def send_zip_to_server
      puts "Sending zip file to the server".green

      file = Faraday::UploadIO.new('marketplace_builder/marketplace_builder.zip', 'application/zip')
      multipart_connection.post("api/marketplace_releases", marketplace_builder: { zip_file: file })
    end

    def wait_for_finish_job(release_reponse)
      release = JSON.parse(release_reponse.body)
      loop do
        response = JSON.parse(connection.get("api/marketplace_releases/#{release['id']}").body)

        puts_status response['status'], response['error']
        break if response['status'] == "success" || response['status'] == "error"

        puts "Waiting 5 sec to check again..."
        sleep 5
      end
    end

    def remove_zip_file
      puts "Removing zip file".green
      FileUtils.rm('marketplace_builder/marketplace_builder.zip')
    end
  end
end
