# frozen_string_literal: true
module ElasticHelper
  def wait_for_elastic_index
    sleep 2
  end
end

World(ElasticHelper)
