# frozen_string_literal: true
class ElasticIndexerUsersByProfileTypeJob < Job
  include Job::LongRunning

  def after_initialize(instance_profile_id)
    @instance_profile_id = instance_profile_id
  end

  def self.priority
    5
  end

  def should_update_index?
    Rails.application.config.use_elastic_search
  end

  def perform
    return unless should_update_index?

    InstanceProfileType.find(@instance_profile_id).users.find_each do |user|
      ElasticIndexerJob.perform(:update, 'User', user.id)
    end
  end
end
