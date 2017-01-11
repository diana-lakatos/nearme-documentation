module Deliveries
  class ProviderSettingsValidator < ActiveModel::Validator
    def validate(record)
      check_api_credentials(record)
    end

    private

    def check_api_credentials(record)
      response = TestConnection.new(record)

      record.errors.add(:base, response.error) unless response.success?
    end

    class TestConnection
      attr_reader :provider

      def initialize(provider)
        @provider = provider
      end

      def success?
        connection.success?
      end

      def error
        connection.body['error_description']
      end

      private

      def connection
        @connection ||= provider.api_client.ping
      end
    end
  end
end
