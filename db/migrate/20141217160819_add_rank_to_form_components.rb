class AddRankToFormComponents < ActiveRecord::Migration
  def change
    add_column :form_components, :rank, :integer, index: true
  end
end
