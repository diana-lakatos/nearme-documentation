class ScopeSpeeStockItem < ActiveRecord::Migration
   SPREE_MODELS = %w{StockItem}

  def up
    SPREE_MODELS.each do |model|
      table_name = "Spree::#{model}".constantize.table_name
      add_column table_name, :instance_id, :integer
      add_index table_name, :instance_id
      add_column table_name, :company_id, :integer
      add_index table_name, :company_id
      add_column table_name, :partner_id, :integer
      add_index table_name, :partner_id
      unless "Spree::#{model}".constantize.column_names.include?('user_id')
        add_column table_name, :user_id, :integer
        add_index table_name, :user_id
      end
    end
  end

  def down
    SPREE_MODELS.each do |model|
      table_name = "Spree::#{model}".constantize.table_name
      remove_column table_name, :instance_id
      remove_column table_name, :company_id
      remove_column table_name, :partner_id
      remove_column table_name, :user_id
    end
  end
end
