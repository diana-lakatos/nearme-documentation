require 'test_helper'

class Utils::DefaultAlertsCreatorTest < ActionDispatch::IntegrationTest

  setup do
    @default_alerts_creator = Utils::DefaultAlertsCreator.new
    FactoryGirl.create(:instance_admin)
  end

  context '#create_all_workflows' do
    should 'create all workflows' do
      Utils::DefaultAlertsCreator::SignUpCreator.expects(:new).returns(stub(:create_all! => true))
      Utils::DefaultAlertsCreator::RecurringBookingCreator.expects(:new).returns(stub(:create_all! => true))
      Utils::DefaultAlertsCreator::PayoutCreator.expects(:new).returns(stub(:create_all! => true))
      Utils::DefaultAlertsCreator::ReservationCreator.expects(:new).returns(stub(:create_all! => true))
      Utils::DefaultAlertsCreator::ListingCreator.expects(:new).returns(stub(:create_all! => true))
      Utils::DefaultAlertsCreator::SupportCreator.expects(:new).returns(stub(:create_all! => true))
      Utils::DefaultAlertsCreator::RfqCreator.expects(:new).returns(stub(:create_all! => true))
      Utils::DefaultAlertsCreator::InstanceAlertsCreator.expects(:new).returns(stub(:create_all! => true))
      Utils::DefaultAlertsCreator::UserMessageCreator.expects(:new).returns(stub(:create_all! => true))
      Utils::DefaultAlertsCreator::DataUploadCreator.expects(:new).returns(stub(:create_all! => true))
      Utils::DefaultAlertsCreator::PaymentGatewayCreator.expects(:new).returns(stub(:create_all! => true))
      @default_alerts_creator.create_all_workflows!
    end
  end



end

