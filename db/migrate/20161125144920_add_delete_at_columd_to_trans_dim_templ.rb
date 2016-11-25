class AddDeleteAtColumdToTransDimTempl < ActiveRecord::Migration
  def change
    add_column :transactable_dimensions_templates, :deleted_at, :datetime
  end
end
