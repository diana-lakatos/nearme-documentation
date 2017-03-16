# frozen_string_literal: true
# TODO: this might be converted into more generic range builder
module Elastic
  class QueryBuilder
    class AvailabilityExceptions
      def initialize(params)
        @params = params
      end

      def prepare
        return unless any?

        add gte: from
        add lte: to
        query
      end

      def as_json(*_args)
        prepare
      end

      def present?
        @params && any?
      end

      private

      def any?
        from || to
      end

      def add(range)
        query.merge range if range
      end

      def query
        @query ||= { not: { range: { 'user_profiles.availability_exceptions' => {} } } }
      end

      def from
        to_date @params[:from]
      end

      def to
        to_date @params[:to]
      end

      def to_date(date)
        Date.parse(date) if date.present?
      end
    end
  end
end
