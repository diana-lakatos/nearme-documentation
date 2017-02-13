# frozen_string_literal: true
class ElasticIndexerJob < Job
  include Job::HighPriority

  def after_initialize(operation, klass, record_id, options = {})
    @operation = operation
    @klass = klass
    @record_id = record_id
    @options = options
  end

  def self.priority
    5
  end

  def perform
    return unless should_update_index?

    if self.class.run_in_background? && settings.values.first['settings']['index']['blocks'].try(:[], 'write') == 'true'
      self.class.perform_later(1.minute.from_now, @operation, @klass, @record_id, @options)
      return
    end

    Rails.logger.info format('Started reindexing ES: %s#%s', @klass, @record_id)

    begin
      case @operation.to_s
      when /index|update/
        record = @klass.constantize.with_deleted.find(@record_id)
        return if record.deleted? || record.try(:draft)
        record.__elasticsearch__.client = client
        record.__elasticsearch__.__send__ "#{@operation}_document"
      when /delete/
        client.delete index: @klass.constantize.index_name, type: @klass.constantize.document_type, id: @record_id
      else raise ArgumentError, "ElasticIndexer Unknown operation '#{@operation}'"
      end
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
    end
  end

  private

  def should_update_index?
    Rails.application.config.use_elastic_search && seacheable_class?
  end

  def seacheable_class?
    PlatformContext.current && PlatformContext.current.instance.searchable_classes.include?(@klass.constantize)
  end

  def client
    @client ||= Elasticsearch::Model.client
  end

  def settings
    @settings ||= client.indices.get_settings index: @klass.constantize.index_name
  end
end
