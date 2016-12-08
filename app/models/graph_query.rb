# frozen_string_literal: true
class GraphQuery < ActiveRecord::Base
  belongs_to :instance

  validates :name, uniqueness: { scope: [:instance_id] }
end
