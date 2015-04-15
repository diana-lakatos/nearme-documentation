class CreateVendorApprovalAlerts < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      puts "Creating vendor approval alerts for #{i.name}"
      PlatformContext.current = PlatformContext.new(i)
      creator = Utils::DefaultAlertsCreator::ListingCreator.new
      creator.create_listing_pending_approval_email!
      creator.create_approved_email!
      Utils::DefaultAlertsCreator::SignUpCreator.new.create_approved_email!
    end
  end

  def down
  end
end
