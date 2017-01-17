class CategorySerializer < ApplicationSerializer
  self.root = false
  attributes :id, :name

  has_many :children
end
