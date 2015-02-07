class AddMailSentAtToOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :request_guest_rating_email_sent_at, :datetime
    add_column :spree_orders, :request_host_and_product_rating_email_sent_at, :datetime
  end
end
