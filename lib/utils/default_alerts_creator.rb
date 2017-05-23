class Utils::DefaultAlertsCreator
  def create_all_workflows!
    Utils::DefaultAlertsCreator::SignUpCreator.new.create_all!
    Utils::DefaultAlertsCreator::ReservationCreator.new.create_all!
    Utils::DefaultAlertsCreator::OfferCreator.new.create_all!
    Utils::DefaultAlertsCreator::PurchaseCreator.new.create_all!
    Utils::DefaultAlertsCreator::ListingCreator.new.create_all!
    Utils::DefaultAlertsCreator::RecurringBookingCreator.new.create_all!
    Utils::DefaultAlertsCreator::PayoutCreator.new.create_all!
    Utils::DefaultAlertsCreator::SupportCreator.new.create_all!
    Utils::DefaultAlertsCreator::RfqCreator.new.create_all!
    Utils::DefaultAlertsCreator::InstanceAlertsCreator.new.create_all!
    Utils::DefaultAlertsCreator::UserMessageCreator.new.create_all!
    Utils::DefaultAlertsCreator::DataUploadCreator.new.create_all!
    Utils::DefaultAlertsCreator::SavedSearchCreator.new.create_all!
    Utils::DefaultAlertsCreator::PaymentGatewayCreator.new.create_all!
    Utils::DefaultAlertsCreator::CollaboratorCreator.new.create_all!
    Utils::DefaultAlertsCreator::GroupCreator.new.create_all!
    Utils::DefaultAlertsCreator::UserCreator.new.create_all!
    Utils::DefaultAlertsCreator::SpamReportCreator.new.create_all!
    Utils::DefaultAlertsCreator::ActivityEventsSummaryCreator.new.create_all!
    Utils::DefaultAlertsCreator::FollowerCreator.new.create_all!
    Utils::DefaultAlertsCreator::CommenterCreator.new.create_all!
    Utils::DefaultAlertsCreator::OrderCreator.new.create_all!
    Utils::DefaultAlertsCreator::RecurringBookingPeriodCreator.new.create_all!
    Utils::DefaultAlertsCreator::MarketplaceReportCreator.new.create_all!
  end
end
