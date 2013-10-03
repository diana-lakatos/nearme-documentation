class AddMissingReferenceIndicies < ActiveRecord::Migration
  def change
    add_index :authentications, :user_id

    add_index :charges, [:reference_id, :reference_type]

    add_index :companies, :creator_id

    add_index :company_industries, [:industry_id, :company_id]

    add_index :domains, [:target_id, :target_type]

    add_index :guest_ratings, :author_id
    add_index :guest_ratings, :subject_id
    add_index :guest_ratings, :reservation_id

    add_index :host_ratings, :author_id
    add_index :host_ratings, :subject_id
    add_index :host_ratings, :reservation_id

    add_index :inquiries, :listing_id
    add_index :inquiries, :inquiring_user_id

    add_index :listings, :location_id
    add_index :listings, :listing_type_id

    add_index :location_amenities, :amenity_id
    add_index :location_amenities, :location_id

    add_index :locations, :location_type_id

    add_index :pages, :instance_id

    add_index :photos, :creator_id
    add_index :photos, [:content_id, :content_type]

    add_index :reservation_periods, :reservation_id

    add_index :reservation_seats, :reservation_period_id
    add_index :reservation_seats, :user_id

    add_index :reservations, :listing_id
    add_index :reservations, :owner_id

    add_index :search_notifications, :user_id

    add_index :themes, [:owner_id, :owner_type]

    add_index :unit_prices, :listing_id

    add_index :user_industries, [:industry_id, :user_id]
  end
end
