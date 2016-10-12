class AddMarketplaceErrorsToGroups < ActiveRecord::Migration
  def self.up
    index = 0
    MarketplaceError.where(error_type: 'Javascript Error').delete_all
  end

  def self.down
    ActiveRecord::Base.connection.execute('DELETE FROM marketplace_error_groups')
    MarketplaceError.update_all(marketplace_error_group_id: nil)
  end
end
