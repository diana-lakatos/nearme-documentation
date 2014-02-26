require 'test_helper'
class CompanySmsNotifierTest < ActiveSupport::TestCase
  setup do
    @company_owner = FactoryGirl.create(:user, :mobile_number => "124456789")
    @company_owner.stubs(:temporary_token).returns('abc')
    @instance = FactoryGirl.create(:instance, :name => 'MyBoat')
    @domain = FactoryGirl.create(:domain, :name => 'notifcations.com', :target => @instance)
    @company = FactoryGirl.create(:company, :creator => @company_owner, :instance => @instance)
    @platform_context = PlatformContext.new.initialize_with_company(@company)
    Googl.stubs(:shorten).with("http://notifcations.com/manage/companies/#{@company.id}/edit?token=abc#company_paypal_email").returns(stub(:short_url => "http://goo.gl/abf324"))
  end

  context '#notify_host_with_confirmation' do
    should "render with the reservation" do
      sms = CompanySmsNotifier.notify_host_of_no_payout_option(@platform_context, @company)
      assert_equal @company_owner.full_mobile_number, sms.to
      assert sms.body =~ Regexp.new("Hi from MyBoat. Your funds transfer is ready. Please add a PayPal account to receive your funds now."), "Sms body does not include expected content: #{sms.body}"
      assert sms.body =~ /http:\/\/goo.gl/
    end
  end
end

