class EsAddAvailability < ActiveRecord::Migration
  def up
    PlatformContext.clear_current
    InstanceProfileType.searchable.each do |ipt|
      ipt.instance.set_context!
      ElasticInstanceIndexerJob.perform(update_type: 'rebuild', only_classes: ['User'])
    end
  end
end
