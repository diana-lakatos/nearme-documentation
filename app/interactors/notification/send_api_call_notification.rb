# frozen_string_literal: true
module Notification
  class SendApiCallNotification < SendNotification
    protected

    def send
      case @notification.format
      when 'http'
        HttpRequest.new(options)
      else
        raise NotImplementedError, "Unsupported format #{@notification.format}. Supported format: http"
      end.deliver
    end

    def options
      {
        endpoint: liquify(@notification.to),
        headers: JSON.parse(liquify(@notification.headers)),
        request_type: @notification.request_type,
        body: liquify(@notification.content)
      }
    end

    def mandatory_fields
      %i(to content request_type)
    end

    class HttpRequest
      def initialize(endpoint:, body:, request_type:, headers: {})
        @endpoint = endpoint
        @request_type = request_type
        @headers = headers
        @body = body
        @use_ssl = @endpoint.starts_with?('https')
        set_headers
        request.body = body
      end

      def deliver
        http.request(request)
      end

      protected

      def http
        @http ||= begin
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = @use_ssl
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE if @use_ssl
          http.read_timeout = 5
          http
        end
      end

      def uri
        @uri ||= URI.parse(@endpoint)
      end

      def request
        @request ||= "Net::HTTP::#{@request_type.capitalize}".constantize.new(uri)
      end

      def set_headers
        @headers.each do |key, value|
          request.add_field(key, value)
        end
      end
    end
  end
end
