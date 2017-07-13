# frozen_string_literal: true
# Updates all indexes for instance
# parameter update_type (optional):
# - refresh - uses ES reindex method to copy data from old index to new one
# - rebuild - loads data from DB, very slow
# parameter only_classes (optional) - pass an array of classes that should be afected by update.
class ElasticInstanceIndexerJob < Job
  include Job::LongRunning

  def after_initialize(update_type: 'refresh')
    @update_type = update_type
  end

  def self.priority
    25
  end

  def perform
    ActiveRecord::Base.logger.silence do
      case @update_type
      when 'rebuild'
        Elastic::InstanceDocuments::Rebuild.new(instance_id).perform
      when 'refresh'
        Elastic::InstanceDocuments::Refresh.new(instance_id).perform
      end
    end
  end

  private

  def instance_id
    PlatformContext.current.instance.id
  end
end
