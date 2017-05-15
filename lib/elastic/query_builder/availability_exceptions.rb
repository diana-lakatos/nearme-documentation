# frozen_string_literal: true
# TODO: this might be converted into more generic range builder
module Elastic
  module QueryBuilder
    class AvailabilityExceptions
      attr_reader :query

      def initialize(params)
        @params = params
        @query = {}
      end

      def prepare
        return unless any?

        add_range gte: from
        add_range lte: to
        query
      end

      def to_h
        prepare
      end

      def present?
        @params && any?
      end

      private

      def any?
        from || to
      end

      def add_range(range)
        return unless range

        query.deep_merge! not: { range: { 'user_profiles.availability_exceptions' => range } }
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
