# frozen_string_literal: true

require './lib/elastic/index'
require './lib/elastic/engine'
require './lib/elastic/index_factory'

module Elastic
  def self.index_for(instance)
    Elastic::Configuration.new(type: instance.name, instance_id: instance.id)
  end

  def self.env
    ENV.fetch 'RAILS_ENV' do
      'development'
    end
  end

  def self.stack_name
    ENV.fetch 'STACK_NAME' do
      'local'
    end
  end

  def self.application_name
    ENV.fetch 'APPLICATION_NAME' do
      'near-me'
    end
  end
end
