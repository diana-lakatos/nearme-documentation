module NearmeMarketplace
  class PullCommand < BaseCommand
    def execute!
      puts "Pull command started!".green

      response = send_request_backup_to_sever
      response = JSON.parse(response.body)
      response = wait_for_finish_job(response['id'])
      download_and_unzip_exported_zip(response)
    end

    private

    def send_request_backup_to_sever
      connection.put("api/marketplace_releases/backup")
    end

    def wait_for_finish_job(release_id)
      loop do
        response = connection.get("api/marketplace_releases/#{release_id}")
        response = JSON.parse(response.body)

        puts_status response['status'], response['error']
        break response if response['status'] == "success" || response['status'] == "error"

        puts "Waiting 5 sec to check again..."
        sleep 5
      end
    end

    def download_and_unzip_exported_zip(release)
      url = release['zip_file']['url']
      url = url.prepend(marketplace_config[endpoint_name]['url']) if url.start_with?('/')

      system "curl -o marketplace_release.zip '#{url}'"
      system "unzip -o marketplace_release.zip -d marketplace_builder"
    end
  end
end
