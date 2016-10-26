class ElasticInstanceIndexerJob < Job
  include Job::LongRunning

  def after_initialize(force = false)
    @force = force
  end

  def self.priority
    25
  end

  def perform
    unless Transactable.__elasticsearch__.client.indices.exists? index: Transactable.index_name
      Transactable.__elasticsearch__.create_index! force: @force
    end
    Transactable.searchable.import force: @force, batch_size: 100
  end
end
