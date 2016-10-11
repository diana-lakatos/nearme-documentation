class AddMarketplaceErrorsToGroups < ActiveRecord::Migration
  def self.up
    index = 0
    MarketplaceError.where(error_type: 'Javascript Error').delete_all
    MarketplaceError.order('id ASC').find_each do |marketplace_error|
      index += 1
      puts "At error #{index}" if index % 10_000 == 0

      group = MarketplaceErrorGroup.where(error_type: marketplace_error.error_type,
                                          message_digest: marketplace_error.message_digest,
                                          instance_id: marketplace_error.instance_id).first_or_create! do |meg|
        meg.message = marketplace_error.message
        meg.instance_id = marketplace_error.instance_id
      end

      group.marketplace_errors << marketplace_error
      group.update_column(:last_occurence, marketplace_error.created_at)
    end
  end

  def self.down
    ActiveRecord::Base.connection.execute('DELETE FROM marketplace_error_groups')
    MarketplaceError.update_all(marketplace_error_group_id: nil)
  end
end
