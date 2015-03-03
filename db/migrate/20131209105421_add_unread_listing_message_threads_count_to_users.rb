class AddUnreadListingMessageThreadsCountToUsers < ActiveRecord::Migration

  class User < ActiveRecord::Base

    has_many :administered_locations,
      :class_name => "Location",
      :foreign_key => "administrator_id",
      :inverse_of => :administrator

    has_many :administered_listings,
      :class_name => "Listing",
      :through => :administered_locations,
      :source => :listings

    has_many :company_users, dependent: :destroy
    has_many :companies, -> { order("company_users.created_at ASC") }, :through => :company_users

    has_many :locations, :through => :companies
    has_many :listings, :through => :locations

    def listings_with_messages
      listings.with_listing_messages + administered_listings.with_listing_messages
    end

    def listing_messages
      ListingMessage.where('owner_id = ? OR listing_id IN(?)', id, listings_with_messages.map(&:id)).order('created_at asc')
    end
  end

  class Location < ActiveRecord::Base
    has_many :listings,
      dependent:  :destroy,
      inverse_of: :location
  end

  class Listing < ActiveRecord::Base
    has_many :listing_messages

    scope :with_listing_messages, joins(:listing_messages).
      group('listings.id HAVING count(listing_messages.id) > 0')
  end

  class ListingMessage < ActiveRecord::Base
    belongs_to :listing
  end

  def get_unread_listing_message_threads(user)
    threaded = user.listing_messages.group_by{|listing_message|
      [listing_message.owner_id, listing_message.listing_id]
    }.sort_by{|key, listing_messages| listing_messages.last.created_at }.reverse
    
    # inbox
    threaded = threaded.reject {|key, listing_messages|
      listing_messages.all?{|listing_message|
        if user.id == listing_message.owner_id
          listing_message.archived_for_owner
        else
          listing_message.archived_for_listing
        end
      }
    }

    # unread
    threaded = threaded.select { |key, listing_messages|
      listing_messages.any?{|listing_message| !listing_message.read? && user.id != listing_message.author_id }
    }

    threaded
  end


  def change
    add_column :users, :unread_listing_message_threads_count, :integer, default: 0

    User.all.each do |user|
      next if user.listing_messages.blank?
      actual_count = get_unread_listing_message_threads(user).size
      user.update_column(:unread_listing_message_threads_count, actual_count)
    end

  end
end