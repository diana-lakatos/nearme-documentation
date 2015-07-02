class ElasticInstanceIndexerJob < Job

  include Job::LongRunning

  def after_initialize(force = false)
    @force = force
  end

  def perform
    begin
      Transactable.searchable.import force: @force
      Spree::Product.searchable.import force: @force
    rescue StandardError => e
      raise e if e.is_a?(Faraday::Error::ConnectionFailed)
    end
  end
end
