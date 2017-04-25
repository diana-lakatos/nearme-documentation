class MarketplaceBuilderSettings < ActiveRecord::Base
  enum status: [:ready, :in_progress, :ready_last_error]

  belongs_to :instance
  belongs_to :marketplace_release
end
