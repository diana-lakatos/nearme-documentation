module SendleApi
  class HttpClient
    def initialize(options)
      @user = options.fetch(:user)
      @password = options.fetch(:password)
      @url = options.fetch(:url)
    end

    def get(path, params = {})
      handle_response connetion.get(path, params)
    end

    def post(path, params)
      handle_response connetion.post(path, params)
    end

    def delete(path, params = {})
      handle_response connetion.delete(path, params)
    end

    private

    def handle_response(response)
      SendleApi::Response.new response
    end

    def connetion
      Faraday.new(url: @url) do |conn|
        conn.request :basic_auth, @user, @password
        conn.request :json
        conn.response :json
        conn.response :logger if ENV['HTTP_LOGGER_LEVEL']
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
