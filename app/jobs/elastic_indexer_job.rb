# frozen_string_literal: true
class ElasticIndexerJob < Job
  include Job::HighPriority

  def after_initialize(operation, klass_name, record_id)
    @operation = operation
    @klass_name = klass_name
    @record_id = record_id
  end

  def self.priority
    5
  end

  def perform
    return unless should_update_index?
    return unless record

    Rails.logger.info format('Started reindexing ES: %s#%s', @klass_name, @record_id)

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
    Elastic::Commands::MarkRecordAsDeleted.new(record).call
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

  def should_update_index?
    Rails.application.config.use_elastic_search
  end

  def index_name
    source_class.index_name
  end

  def source_class
    @klass_name.constantize
  end
end
