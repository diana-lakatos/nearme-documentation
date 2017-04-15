# frozen_string_literal: true

require './lib/elastic/index'
require './lib/elastic/index_types'
require './lib/elastic/engine'
require './lib/elastic/index_factory'

module Elastic
  def self.index_for(instance)
    default_index_name_builder(instance).build
  end

  def self.default_index_name_builder(instance)
    Elastic::IndexNameBuilder.new(ENV['RAILS_ENV'], instance.id, 'development', 'user-transactables')
  end
end
