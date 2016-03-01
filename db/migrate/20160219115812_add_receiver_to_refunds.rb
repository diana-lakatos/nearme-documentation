class AddReceiverToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :receiver, :string
  end
end
