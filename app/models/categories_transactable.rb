class CategoriesTransactable < ActiveRecord::Base
  belongs_to :category
  belongs_to :transactable
end
