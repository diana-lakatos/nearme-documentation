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

    Rails.logger.info format('Started reindexing ES: %s#%s', @klass, @record_id)

    case @operation.to_s
    when 'index', 'update', 'delete'
      update_document
    else
      raise ArgumentError, "ElasticIndexer Unknown operation '#{@operation}'"
    end
  end

  private

  def update_document
    return if record.try(:draft)

    record.__elasticsearch__.tap do |es|
      es.client = client
      es.__send__ "#{operation}_document", update_params
    end
  end

  # this sucks
  def update_params
    return {} unless PlatformContext.current.instance.multiple_types?
    return {} unless record.class.mapping.options.key? :_parent

    { parent: record.__parent_id }
  end

  def operation
    @operation.to_s
  end

  def record
    @record ||= source_class.with_deleted.find(@record_id)
  end

  def postpone
    self.class.perform_later(1.minute.from_now, @operation, @klass, @record_id, @options)
  end

  # check if index is writeable
  def delay_indexing?
    self.class.run_in_background? && settings.values.first['settings']['index']['blocks'].try(:[], 'write') == 'true'
  end

  def should_update_index?
    Rails.application.config.use_elastic_search && seacheable_class?
  end

  def seacheable_class?
    PlatformContext.current && PlatformContext.current.instance.searchable_classes.include?(source_class)
  end

  def client
    @client ||= Elasticsearch::Model.client
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
