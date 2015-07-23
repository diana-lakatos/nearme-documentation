module Searchable
  extend ActiveSupport::Concern

  included do    
    include Elasticsearch::Model
    
      #include Elasticsearch::Model::Callbacks
      after_commit lambda { ElasticIndexerJob.perform(:index, self.class.to_s, self.id) }, on: :create
      after_commit lambda { ElasticIndexerJob.perform(:update, self.class.to_s, self.id) }, on: :update
      after_commit lambda { ElasticIndexerJob.perform(:delete, self.class.to_s, self.id) }, on: :destroy

    include "#{self.to_s.demodulize.pluralize}Index".constantize
  end
end