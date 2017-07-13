# frozen_string_literal: true
module Elastic
  module Commands
    class InstantIndexRecord
      attr_reader :record

      def initialize(record)
        @record = record
      end

      def call
        IndexRecord.new(record).call
        RefreshIndex.new(record.class).call
      end
    end
  end
end
