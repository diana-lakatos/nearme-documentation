# frozen_string_literal: true

Given /^Localdriva instance is loaded$/ do
  @instance = Instance.first
  PaymentGateway.where(instance_id: @instance.id).destroy_all
  builder = MarketplaceBuilder::Builder.new(
    @instance.id,
    File.join(Rails.root, 'marketplaces/localdriva'),
    MarketplaceBuilder::Loader::AVAILABLE_CREATORS_LIST - [MarketplaceBuilder::Creators::TranslationsCreator]
  )
  builder.execute!
  @instance.set_context!
  FormComponentToFormConfiguration.new(Instance.where(id: @instance.id)).go!
end

Given /^a localdriva driver exists$/ do
  driver = FactoryGirl.build(:driver)
  driver.phone = '0987654321'
  driver.email = 'driver@near-me.com'
  driver.buyer_profile.properties.driver_type_unit = 1
  driver.buyer_profile.properties.hourly_price = 39
  driver.buyer_profile.properties.short_bio = 'Bio'
  driver.buyer_profile.properties.vehicle_type = 'Veh Type'
  driver.buyer_profile.properties.vehicle_model = 'Model'
  driver.buyer_profile.properties.full_bio = 'Bio'
  driver.buyer_profile.properties.vehicle_capacity = 4
  driver.buyer_profile.properties.vehicle_year = '1239'
  driver.buyer_profile.properties.vehicle_description = 'Desc'
  driver.buyer_profile.properties.driver_category = 'Standard'
  driver.save!
  store_model('driver', 'driver', driver)
end

Given /^localdriva booking exists$/ do
  transactable = FactoryGirl.build(:transactable_offer, creator: model(:passenger))
  transactable.properties.trip_start_time = '9:00'
  transactable.properties.number_of_passengers = 2
  transactable.properties.duration = 2
  transactable.properties.trip_start_date = '10/04/2017'
  TransactableType::OfferAction.first.pricings.each do |pricing|
    unless transactable.action_type.pricings.where(transactable_type_pricing: pricing).exists?
      pricing.build_transactable_pricing(transactable.action_type)
    end
  end
  transactable.save!
  store_model('transactable', 'transactable', transactable)
end

Then /^I should see correct price of ([0-9.]+)$/ do |price|
  within("article#transactable_#{model(:transactable).id}") do
    assert_includes page.find(:css, 'div.user-profile > p > span').text, "AUD $#{price}"
  end
end

Then /^I should see correct service fee of ([0-9.]+)$/ do |price|
  within("article#transactable_#{model(:transactable).id}") do
    assert_includes page.find(:css, 'div.user-profile > p > span').text, "AUD $#{price}"
  end
end

Then /^I accept booking$/ do
  within("article#transactable_#{model(:transactable).id}") do
    click_link('Accept Booking')
  end
  click_button 'Request Booking'
  page.should have_content('Your reservation has been made!')
end

Given /^service fee for pricing (\w+) is set to ([0-9.]+)\%$/ do |pricing, percent|
  TransactableType::OfferAction.first.pricing_for(pricing).update(service_fee_guest_percent: percent)
end

Then /^I edit driver's type to (\w+)$/ do |driver_type|
  driver = model(:driver)
  driver.buyer_properties.driver_category = driver_type
  driver.buyer_properties.driver_type_unit = %w(Standard Pro Plus).index(driver_type) + 1
  driver.save!
end

Given /^service fee for action is set to ([0-9.]+)\%$/ do |percent|
  TransactableType::ActionType.update_all(service_fee_guest_percent: percent)
end

And /^offer shoud have total of: ([0-9.]+) and fee of ([0-9.]+)$/ do |total, fee|
  offer = Offer.last
  assert_equal total.to_f, offer.total_amount.to_f
  assert_equal fee.to_f, offer.service_fee_amount_guest.to_f
end

And /^driver has valid merchant account$/ do
  step('I stub sending stripe documents')
  model('driver').update_attribute(:current_sign_in_ip, '1.1.1.1')
  company = model('driver').default_company
  ma = FactoryGirl.build :stripe_connect_merchant_account, merchantable: company, tos: '1', payment_gateway: model('direct_stripe_sconnect_payment_gateway_au')
  # We don't want to send document to Stripe as VCR has some problems with files
  ma.merchantable.creator.stubs(:email).returns('tomek@near-me.com')
  ma.merchantable.stubs(:name).returns('NearMe')
  ma.save!
end
