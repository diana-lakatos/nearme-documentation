class ElasticIndexerJob < Job

  include Job::HighPriority

  def after_initialize(operation, klass, record_id, options = {})
    @operation = operation
    @klass = klass
    @record_id = record_id
    @options = options
  end

  def perform
    return if Rails.env.test?
    client = Elasticsearch::Model.client
    begin
      case @operation.to_s
        when /index|update/
          record = @klass.constantize.find(@record_id)
          record.__elasticsearch__.client = client
          record.__elasticsearch__.__send__ "#{@operation}_document"
        when /delete/
          client.delete index: @klass.constantize.index_name, type: @klass.constantize.document_type, id: @record_id
        else raise ArgumentError, "ElasticIndexer Unknown operation '#{@operation}'"
      end
    rescue StandardError => e
      raise e if e.is_a?(Faraday::Error::ConnectionFailed) && !Rails.env.development?
    end
  end
end
