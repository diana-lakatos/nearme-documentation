class MoveListingMessagesToUserMessages < ActiveRecord::Migration

  class User < ActiveRecord::Base
  end

  class Company < ActiveRecord::Base
    belongs_to :creator, class_name: "User"
  end

  class Location < ActiveRecord::Base
    belongs_to :administrator, class_name: "User"
    belongs_to :company
    delegate :creator, to: :company, allow_nil: true

    def administrator
      super.presence || creator
    end
  end

  class Listing < ActiveRecord::Base
    belongs_to :location

    delegate :administrator, :to => :location, :allow_nil => true
  end

  class ListingMessage < ActiveRecord::Base
    belongs_to :listing
  end

  class UserMessage < ActiveRecord::Base
  end

  def up
    ListingMessage.all.each do |lm|
      UserMessage.create!({
        thread_owner_id: lm.owner_id,
        thread_recipient_id: lm.listing.administrator.try(:id),
        author_id: lm.author_id,
        thread_context_id: lm.listing_id,
        thread_context_type: 'Listing',
        body: lm.body,
        read: lm.read,
        archived_for_owner: lm.archived_for_owner,
        archived_for_recipient: lm.archived_for_listing,
        created_at: lm.created_at
      })
    end
  end

  def down
  end
end
