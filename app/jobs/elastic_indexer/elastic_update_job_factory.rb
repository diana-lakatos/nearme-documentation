module ElasticIndexer
  # kinda dispatcher
  class ElasticUpdateJobFactory
    attr_reader :record
    def initialize(record)
      @record = record
    end

    def perform
      return unless parent

      ElasticIndexerJob.perform(:update, parent.class.to_s, parent.id)
    end

    private

    def parent
      @parent ||= find_parent
    end

    # there will be more
    def find_parent
      case record
      when CustomImage then record.owner.user
      when User then record
      end
    end
  end
end
