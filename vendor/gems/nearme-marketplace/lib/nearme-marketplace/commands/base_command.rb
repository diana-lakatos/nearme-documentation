module NearmeMarketplace
  class BaseCommand
    def handle_server_response(response)
      if [200, 201, 302].include? response.status
        puts_status "success"
      else
        puts_status "error", response.body
      end
    end

    def connection
      @connection ||= Faraday.new(faraday_basic_hash)
    end

    def multipart_connection
      @connection ||= Faraday.new(faraday_basic_hash) do |conn|
        conn.request :multipart
        conn.request :url_encoded
        conn.adapter :net_http
      end
    end

    def faraday_basic_hash
      {
        url: marketplace_config[endpoint_name]['url'],
        headers: {
          'Accept' => 'application/vnd.nearme.v3+json',
          'Authorization' => "Token token=#{marketplace_config[endpoint_name]['api_key']}",
          'UserAuthorization' => marketplace_config['user_key']
        }
      }
    end

    def marketplace_config
      @config ||= JSON.parse(File.read('marketplace_builder/.endpoints'))
    end

    def puts_status(status, message = nil)
      if status == "success"
        puts "Status: #{status}".green
      else
        puts "*".red * 20
        puts "Status: #{status}"
        puts message if message != nil
        puts "*".red * 20
      end
    end

    def endpoint_name
      ENV["ENDPOINT"] || 'local'
    end
  end
end
