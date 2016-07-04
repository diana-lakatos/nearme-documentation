class ElasticBulkUpdateJob < Job

  def after_initialize(klass, updates_hash)
    @klass = klass
    @updates_hash = updates_hash
  end

  def self.priority
    5
  end

  def perform
    return unless Rails.application.config.use_elastic_search
    begin
      @klass.__elasticsearch__.client.bulk body: build_body
    rescue StandardError => e
      raise e if e.is_a?(Faraday::Error::ConnectionFailed) && !Rails.env.development?
    end
  end

  def build_body
    @updates_hash.map do |id, changes|
      {
        update: {
          _index: @klass.index_name,
          _type: @klass.document_type,
          _id: id,
          data: { doc: changes }
        }
      }
    end
  end
end
