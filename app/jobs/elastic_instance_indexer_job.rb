# Updates all indexes for instance
# parameter update_type (optional):
# - refresh - uses ES reindex method to copy data from old index to new one
# - rebuild - loads data from DB, very slow
# parameter only_classes (optional) - pass an array of classes that should be afected by update.
class ElasticInstanceIndexerJob < Job
  include Job::LongRunning

  def after_initialize(update_type: 'refresh', only_classes: [])
    @update_type = update_type
    @only_classes = only_classes.map(&:constantize)
  end

  def self.priority
    25
  end

  def perform
    klasses = @only_classes.presence || Instance::CLASSES_WITH_ES_INDEX
    klasses.each do |klass|
      klass.indexer_helper.with_alias do |new_index_name, old_index_name|
        case @update_type
        when 'rebuild'
          klass.__elasticsearch__.index_name = new_index_name
          klass.searchable.import batch_size: 50
        when 'refresh'
          klass.__elasticsearch__.client.reindex body: {
            source: { index: old_index_name }, dest: { index: new_index_name }
          }
        end
      end
    end
  end
end
