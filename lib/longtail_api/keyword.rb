# frozen_string_literal: true
class LongtailApi
  class Keyword
    class MaxAttemptReached < StandardError
    end
    class InvalidResponse < StandardError
    end
    TOO_MANY_ATTEMPTS_ERROR = 'Too Many Attempts.'
    MAX_ATTEMPTS = 50

    def initialize(endpoint:, data:, campaign:)
      @endpoint = endpoint
      @data = data
      @campaign = campaign
    end

    def body
      JSON.parse(api_response)
    rescue JSON::ParserError
      raise InvalidResponse, api_response
    end

    def slug
      @data['attributes']['slug']
    end

    def path
      @data['attributes']['url'][1..-1]
    end

    def id
      @data['id']
    end

    protected

    def endpoint_path
      "/search/#{@campaign}/#{slug}"
    end

    def api_response
      return @api_response if @api_response.present?
      call_result = @endpoint.call(endpoint_path)
      if call_result == TOO_MANY_ATTEMPTS_ERROR
        within_max_attempts do
          sleep(5)
          call_result = @endpoint.call(endpoint_path)
        end
      end
      @max_attemps = 0
      @api_response = call_result
    end

    def within_max_attempts
      @max_attemps ||= 0
      raise MaxAttemptReached, "Max attempts to fetch keyword #{slug} reached" if @max_attemps < MAX_ATTEMPTS
      yield
    end
  end
end
