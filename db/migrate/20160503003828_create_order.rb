class CreateOrder < ActiveRecord::Migration
  def change
    create_table :orders do |t|

      t.integer  "instance_id",               index: true
      t.integer  "user_id",                   index: true
      t.integer  "owner_id",                  index: true
      t.integer  "creator_id",                index: true
      t.integer  "company_id",                index: true
      t.integer  "partner_id",                index: true
      t.integer  "transactable_id",           index: true
      t.integer  "transactable_pricing_id",   index: true
      t.integer  "reservation_type_id",       index: true
      t.integer  "shipping_address_id",       index: true
      t.integer  "billing_address_id",        index: true

      t.string   "currency",                    index: true
      t.string   "state",                                         limit: 255
      t.string   "state",                                         limit: 255
      t.string   "type",                                          limit: 255
      t.string   "time_zone"
      t.boolean  "use_billing",                                                   default: false,   null: false

      t.string   "rejection_reason",                              limit: 255
      t.string   "completed_form_component_ids",                              limit: 255
      t.integer  "cancellation_policy_hours_for_cancellation",                                        default: 0
      t.integer  "cancellation_policy_penalty_percentage",                                            default: 0
      t.integer  "cancellation_policy_penalty_hours",                                            default: 0
      t.integer  "minimum_booking_minutes",                                                           default: 60
      t.integer  "book_it_out_discount"
      t.text     "guest_notes"
      t.hstore   "properties"
      t.datetime "pending_guest_confirmation"

      t.date     "paid_until"
      t.date     "next_charge_date"

      t.datetime "starts_at"
      t.datetime "expires_at"
      t.datetime "ends_at"
      t.datetime "cancelled_at"
      t.datetime "confirmed_at"
      t.datetime "archived_at"
      t.datetime "deleted_at"
      t.boolean  "insurance_enabled",                                                   default: false,   null: false

      t.string   "delivery_type",                                 limit: 255
      t.string   "confirmation_email",                            limit: 255
      t.text     "comment"
      t.boolean  "create_charge"
      t.boolean  "listings_public",                                                                   default: true
      t.datetime "request_guest_rating_email_sent_at"
      t.datetime "request_host_and_product_rating_email_sent_at"
      t.string   "booking_type",                                  limit: 255
      # t.integer  "hours_to_expiration",                                                               default: 24,        null: false
      t.integer  "exclusive_price_cents"
      t.integer  "quantity"

      t.datetime "created_at"
      t.datetime "updated_at"


    end

    create_table :line_items do |t|
      t.integer  "instance_id", index: true
      t.integer  "user_id", index: true
      t.integer  "company_id", index: true
      t.integer  "partner_id", index: true

      t.integer  "line_item_source_id", index: true
      t.string   "line_item_source_type"
      t.integer  "line_itemable_id", index: true
      t.string   "line_itemable_type"

      t.integer  "transactable_pricing_id", index: true

      t.string   "name"
      t.string   "type",                                          limit: 255
      t.integer  "unit_price_cents", default: 0
      t.float    "quantity", default: 0
      t.string   "receiver"
      t.boolean   "optional"

      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"

    end
  end
end
