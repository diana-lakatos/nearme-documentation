class AddLabelToDataSources < ActiveRecord::Migration
  def change
    add_column :data_sources, :label, :string
  end
end
