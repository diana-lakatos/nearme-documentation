module Searchable
  extend ActiveSupport::Concern

  included do    
    include Elasticsearch::Model
    
    if !Rails.env.test?
      include Elasticsearch::Model::Callbacks
    end

    include "#{self.to_s.demodulize.pluralize}Index".constantize
  end
end