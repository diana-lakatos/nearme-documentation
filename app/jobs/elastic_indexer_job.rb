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
    return postpone if delay_indexing?
    return unless record

    Rails.logger.info format('Started reindexing ES: %s#%s', @klass, @record_id)

    case operation
    when 'index', 'update'
      update_document
    when 'delete'
      mark_as_deleted
    else
      raise ArgumentError, "ElasticIndexer Unknown operation '#{operation}'"
    end
  end

  private

  def mark_as_deleted
    Elastic::Commands::MarkAsDeleted.new(record).call
  end

  def update_document
    Elastic::Commands::IndexRecord.new(record).call
  end

  def operation
    @operation.to_s
  end

  def record
    @record ||= source_class.indexable.find_by(id: @record_id)
  end

  def postpone
    self.class.perform_later(1.minute.from_now, operation, @klass, @record_id, @options)
  end

  # check if index is writeable
  def delay_indexing?
    self.class.run_in_background? && settings.values.first['settings']['index']['blocks'].try(:[], 'write') == 'true'
  end

  def should_update_index?
    Rails.application.config.use_elastic_search
  end

  def settings
    @settings ||= client.indices.get_settings index: index_name
  end

  def index_name
    source_class.index_name
  end

  def source_class
    @klass.constantize
  end
end
