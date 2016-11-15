# frozen_string_literal: true
module SendleApi
  class Response
    SUCCESS_CODE = 200..207
    attr_reader :success, :response

    def initialize(response)
      @response = response
    end

    def success?
      SUCCESS_CODE.include? response.status
    end

    delegate :body, to: :response

    def inspect
      [success?, body]
    end
  end
end
