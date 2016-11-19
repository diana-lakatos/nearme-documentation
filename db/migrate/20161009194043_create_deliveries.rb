# frozen_string_literal: true
# NOTE: order should have only at most 2 active order-addresses
class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.integer :order_id, null: false # => Order

      t.date :pickup_date, null: false
      t.integer :sender_address_id, null: false # => OrderAddress
      t.integer :receiver_address_id, null: false # => OrderAddress

      t.string :courier # delivery_provider

      t.string :status # [draft|unconfirmed, proposal, confirmed, completed]
      t.string :notes # instructions

      # post-delivery data

      t.string :order_reference # once confirmed
      t.string :tracking_url
      t.string :tracking_reference

      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end
