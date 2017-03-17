# frozen_string_literal: true
class LongtailApi
  class KeywordListIterator
    attr_reader :campaign
    class InvalidResponse < StandardError
    end

    def initialize(endpoint, campaign:)
      @campaign = campaign
      @endpoint = endpoint
      fetch!
    end

    def next
      next_page! if all_keywords_parsed? && next_page_available?
      @keywords['data'].shift
    end

    protected

    def next_page!
      fetch!(@keywords['links']['next'])
    end

    def all_keywords_parsed?
      @keywords['data'].blank?
    end

    def next_page_available?
      @keywords['links']['next'].present?
    end

    def fetch!(url = nil)
      url ||= "/keywords/#{@campaign}"
      response = @endpoint.call(url)
      begin
        @keywords = JSON.parse(response)
        raise InvalidResponse, response unless @keywords['data'].is_a?(Array)
        raise InvalidResponse, response unless @keywords['links'].present?
      rescue JSON::ParserError
        raise InvalidResponse, response
      end
    end
  end
end
