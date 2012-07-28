class ListingOrganization < ActiveRecord::Base
  belongs_to :listing
  belongs_to :organization
end
