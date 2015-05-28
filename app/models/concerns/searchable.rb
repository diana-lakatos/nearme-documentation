module Searchable
  extend ActiveSupport::Concern

  included do    
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    include "#{self.to_s.demodulize.pluralize}Index".constantize
  end
end