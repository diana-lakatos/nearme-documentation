# frozen_string_literal: true
require Rails.root.join('lib', 'tasks', 'uot', 'uot_setup.rb')

def click_accept_button
  page.execute_script("$('.dialog__actions button').trigger('click')")
end

Given /^UoT instance is loaded$/ do
  @instance = Instance.first
  PaymentGateway.where(instance_id: @instance.id).destroy_all
  @instance.update_attributes(
    split_registration: true,
    enable_reply_button_on_host_reservations: true,
    hidden_ui_controls: {
      'main_menu/cta': 1,
      'dashboard/offers': 1,
      'dashboard/user_bids': 1,
      'dashboard/host_reservations': 1,
      'main_menu/my_bookings': 1
    },
    skip_company: true,
    click_to_call: true,
    wish_lists_enabled: true,
    default_currency: 'USD',
    default_country: 'United States',
    force_accepting_tos: true,
    user_blogs_enabled: true,
    force_fill_in_wizard_form: true
  )

  setup = UotSetup.new(@instance)
  setup.create_transactable_types!
  setup.create_custom_attributes!
  setup.create_custom_model!
  setup.create_categories!
  setup.create_or_update_form_components!
  setup.set_theme_options
  setup.create_content_holders
  setup.create_views

  # setup.create_translations
  # setup.create_workflow_alerts
  FormComponentToFormConfiguration.new(Instance.where(id: @instance.id)).go!
  enquirer = FactoryGirl.create(:enquirer)
  store_model('enquirer', 'enquirer', enquirer)
  setup.expire_cache
end

Given /^someone created unconfirmed_offer for registered_lister$/ do
  enquirer = model!('enquirer')
  enquirer.buyer_profile.category_ids = [Category.find_by(name: 'Industry').children.first.id,
                                         Category.find_by(name: 'Area Of Expertise').children.first.id]
  enquirer.save!
  FactoryGirl.create(:company, creator: enquirer)
  offer = FactoryGirl.create(:unconfirmed_offer, user: @instance.buyer_profile_type.users.first)
  lister = offer.transactable.creator
  company = lister.companies.build(name: 'Test Company', completed_at: Time.current)
  lister.get_seller_profile
  lister.seller_profile.mark_as_onboarded!
  lister.save!
  location = FactoryGirl.create(:location, company: company)
  offer.transactable.update_attributes(location: location, company: company)
  offer.update_attribute(:company, location.company)
  store_model('registered_lister', 'registered_lister', offer.transactable.creator)
end

When /^I fill all required buyer profile information$/ do
  Category.update_all('mandatory = false')
  step 'I upload avatar'
  fill_in 'user[current_address_attributes][address]', with: 'usa'
  fill_in 'user[buyer_profile_attributes][properties_attributes][linkedin_url]', with: 'http://linkedin.com/tomek'
  fill_in 'user[buyer_profile_attributes][properties_attributes][hourly_rate_decimal]', with: '1'
  fill_in 'user[buyer_profile_attributes][properties_attributes][bio]', with: 'Bio'
end

When /^I fill all required seller profile information$/ do
  Category.update_all('mandatory = false')
  step 'I upload avatar'
  fill_in 'user[companies_attributes][0][name]', with: 'Appko'
  fill_in 'user[current_address_attributes][address]', with: 'usa'
  fill_in 'user[seller_profile_attributes][properties_attributes][linkedin_url]', with: 'http://linkedin.com/tomek'
end

Then /^I can add new project$/ do
  fill_in 'transactable[name]', with: 'Cucumber project'
  fill_in 'transactable[properties_attributes][about_company]', with: 'About me'
  fill_in 'transactable[properties_attributes][estimation]', with: '1 week'
  fill_in 'transactable[properties_attributes][deadline]', with: '11-01-2022'
  click_button 'Save'
end

And /^only credit_card payment_method is set$/ do
  model('stripe_connect_payment_gateway').payment_methods.ach.destroy_all
end

And /^I invite enquirer to my project$/ do
  page.should have_css('a[data-project-invite-trigger]')
  find('a[data-project-invite-trigger]').click
  page.should have_css('.project-invite-content form button.button-a')
  page.find('.project-invite-content form button.button-a').click
  page.should_not have_css('.project-invite-content form button.button-a')
  assert Transactable.last.transactable_collaborators.any?
end

When /^I accept the offer$/ do
  page.should have_css('.accept-link')
  page.execute_script("$('.accept-link').eq(0).click()")
  wait_modal_loaded('.dialog[aria-hidden="false"]')
  page.should have_css('.nm-credit-card-fields')
end

Then /^fill ACH payment form$/ do
  work_in_modal('.dialog[aria-hidden="false"]') do
    fill_new_ach_fields
    click_accept_button
    wait_for_ajax
  end
end

Then /^I fill credit card payment subscription form$/ do
  work_in_modal('.dialog[aria-hidden="false"]') do
    select_add_new_cc
    # click_accept_button # Submit empty form to check validation
    # page.should have_css('.control-group p.error-block', count: 4)
    fill_new_credit_card_fields
    click_accept_button
    wait_for_ajax
  end
  page.should have_content 'You have successfuly added credit card and accepted an offer.'
end

Then /^I fill credit card payment form$/ do
  work_in_modal('.dialog[aria-hidden="false"]') do
    select_add_new_cc
    fill_new_credit_card_fields
    click_accept_button
    wait_for_ajax
  end
  page.should have_content 'Payment captured'
end

Then /^offer is confirmed$/ do
  first('.table-responsive').should have_text('Accepted')
  assert Offer.last.confirmed?
end

And /^my credit card is saved$/ do
  find('#dashboard-nav-credit_cards a', visible: false).trigger('click')
  page.should have_text('Manage Credit Cards')
  # TODO: Fix test. For some reason last 4 digits are not visible on this page in tests
  # Feature is fixed and tested manually, just need to figure out why tests are not working
  # See view: payment_gateways/credit_cards/_credit_card.html.haml
  page.should have_text('**** **** ****')
end

Then /^I should see modal with payout missing information$/ do
  wait_modal_loaded('.dialog[aria-hidden="false"]')
  page.should have_text('Payment Transfers for your profile must be set')
end

And /^payment for (\d+)\$ was created$/ do |amount|
  assert Offer.last.paid?
  assert_equal amount.to_money, Payment.last.total_amount
end

Then(/^I fill (time|item) expenses with:$/) do |expense_type, table|
  table.raw.each do |expense|
    page.should have_text("Add #{expense_type} expenses")
    click_link("Add #{expense_type} expenses")
    within(all('.time-tracking-entry').last) do
      all('input, textarea').each_with_index do |input, index|
        input.set(expense[index])
      end
    end
  end
end

Then /^unaccepted order item should be generated$/ do
  order_item_scope = model('confirmed offer').order_items.unpaid.pending
  assert_equal 1, order_item_scope.count
  assert_equal 4, (invoice = order_item_scope.last).line_items.count
  assert_equal 1_100_000, invoice.total_amount_cents
  assert_equal 1_100_000, invoice.total_amount_cents
end

And /^30\% host fee should be added to each time expense\:$/ do |table|
  invoice = model('confirmed offer').order_items.last
  assert_equal invoice.service_fee_amount_host, table.raw.last.last.to_money
end

And /^Approve should be disabled$/ do
  expect(page).to have_button('Approve', disabled: true)
end

And /^registered_enquirer has valid merchant account$/ do
  step('I stub sending stripe documents')
  model('registered_enquirer').update_attribute(:current_sign_in_ip, '1.1.1.1')
  company = model('registered_enquirer').default_company
  ma = FactoryGirl.build :stripe_connect_merchant_account, merchantable: company, tos: '1', payment_gateway: model('direct_stripe_sconnect_payment_gateway')
  # We don't want to send document to Stripe as VCR has some problems with files
  ma.merchantable.creator.stubs(:email).returns('tomek@near-me.com')
  ma.merchantable.stubs(:name).returns('NearMe')
  ma.save!
end

And /^I stub sending stripe documents$/ do
  MerchantAccountOwner::StripeConnectMerchantAccountOwner.any_instance.stubs(:upload_document).returns(nil)
  MerchantAccount::StripeConnectMerchantAccount.any_instance.stubs(:tos_acceptance_timestamp).returns(1_487_963_976)
end

When /^I come back when registered_enquirer has valid merchant account$/ do
  step('registered_enquirer has valid merchant account')
  page.evaluate_script('window.location.reload()')
end

When /^I approve first invoice$/ do
  page.should have_css("input[value='Approve']")
  first("input[value='Approve']").click
end

When /^I reject other invoice$/ do
  click_link('Reject')
  wait_modal_loaded('.dialog[aria-hidden="false"]')
  fill_in 'recurring_booking_period[rejection_reason]', with: 'Cancel for no reason.'
  click_button 'Reject'
end

Then /I verify invoices state:$/ do |table|
  offer = model('confirmed_offer: "Order"')
  assert (payment_source = offer.payment_subscription.payment_source).success?
  assert_equal payment_source, offer.order_items.paid.first.payment.payment_source

  table.hashes.map do |hash|
    invoice = model(hash['invoice'])
    assert_equal hash['state'], invoice.state
    assert_equal hash['total'].to_money, invoice.total_amount
    assert_equal hash['payment state'], invoice.payment.try(:state).to_s
    assert_equal hash['payment total'].to_money, invoice.payment ? invoice.payment.total_amount : 0.to_money
  end
end

When /I open (\w+) payment method section$/ do |payment_method_name|
  find("div[data-payment-method-type='#{payment_method_name}'] .payment-method-header").trigger('click')
end

When /^I cancel the project$/ do
  click_link('Cancel Project')
end

And /^finders fee is set to (\d+)\$$/ do |amount_dollars|
  MerchantFee.last.update_attribute :amount_cents, amount_dollars.to_money.cents
end

And /^paid payment for (\d+)\$ should exist$/ do |amount_dollars|
  assert_equal 1, Payment.paid.count
  assert_equal amount_dollars.to_money, Payment.paid.last.total_amount
end

And /^I stub (.*) creation with latest VCR$/ do |source|
  # We need to stub it with last received token, obtained via Stripe.js

  file = File.join(Rails.root, 'features', 'vcr_cassettes', 'cucumber_tags', 'offer_flow.yml')
  if File.exist?(file)
    if source == 'credit_card'
      token = File.open(file).read.match(/string: email=lister%40near-me.com&card=tok_(.+)/)
      CreditCard.any_instance.stubs(:credit_card_token).returns('tok_' + token[1]) if token.present? && token[1]
    else
      token = File.open(file).read.match(/string: description=lister%40near-me.com&source=btok_(.+)/)
      BankAccount.any_instance.stubs(:public_token).returns('btok_' + token[1]) if token.present? && token[1]
    end
  end
end

Given /^credit_card is prcessed with Stripe$/ do
  offer = model('confirmed_offer')
  offer.payment_subscription.payment_source.destroy
  offer.payment_subscription.update_attributes(payment_source_id: nil, payment_source_type: nil)
  offer.payment_subscription.reload
  offer.payment_subscription.credit_card_attributes = FactoryGirl.attributes_for(:credit_card_attributes).reject { |k, _v| k == :response }
  offer.payment_subscription.process!
  offer.payment_subscription.save!
end

And /^registered_enquirer default_company\'s name is "My Company"$/ do
  model('registered_enquirer').default_company.update_attribute(:name, 'My Company')
end
