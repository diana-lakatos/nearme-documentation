class RenameOrderToPositionInSupportFaqs < ActiveRecord::Migration
  def change
    rename_column :support_faqs, :order, :position
  end
end
