module ElasticIndexer
  # kinda dispatcher
  class ElasticUpdateJobFactory
    attr_reader :record
    def initialize(record)
      @record = record
    end

    def perform
      return unless root

      ElasticIndexerJob.perform(:update, root.class.to_s, root.id)
    end

    private

    def root
      @root ||= AggregateRoot.find(record)
    end

    class AggregateRoot
      attr_reader :record

      def self.find(record)
        new(record).root
      end

      def initialize(record)
        @record = record
      end

      # TODO: to be removed
      def root
        case record
        when CustomImage then
          case record.owner
          when UserProfile then record.owner.user
          when Customization then record.owner.customizable.user
          end
        when User then record
        end
      end
    end
  end
end
