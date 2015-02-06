class MoveSentEmailDataFromOrderToLineItem < ActiveRecord::Migration
  def up
    add_column :spree_line_items, :request_guest_rating_email_sent_at, :datetime
    add_column :spree_line_items, :request_host_and_product_rating_email_sent_at, :datetime
    remove_column :spree_orders, :request_guest_rating_email_sent_at
    remove_column :spree_orders, :request_host_and_product_rating_email_sent_at
  end

  def down
    add_column :spree_orders, :request_guest_rating_email_sent_at, :datetime
    add_column :spree_orders, :request_host_and_product_rating_email_sent_at, :datetime
    remove_column :spree_line_items, :request_guest_rating_email_sent_at
    remove_column :spree_line_items, :request_host_and_product_rating_email_sent_at
  end
end
