# frozen_string_literal: true
class LongtailApi
  class Endpoint
    def initialize(host:, token:)
      @host = host
      @token = token
    end

    def call(path)
      url = URI.parse(build_url(path))
      http = Net::HTTP.new(url.host, url.port)
      req = Net::HTTP::Get.new(url)
      req.add_field('Authorization', "Bearer #{@token}")
      response = http.request(req)
      response.body
    end

    protected

    def build_url(path)
      if path.include?(@host)
        path
      else
        "#{@host}#{normalize(path)}"
      end
    end

    def normalize(path)
      path.first == '/' ? path : "/#{path}"
    end
  end
end
