require 'test_helper'

class ShippoTest < ActionView::TestCase
  setup do
    @user = FactoryGirl.create(:user)
  end

  def check_all_params_not_blank(params_list, object)
    result = true
    params_list.each do |param|
      if !object.respond_to?(param) || object.send(param).blank?
        result = false
        break
      end
    end
    result
  end

  def setup_stubs_for_shippo_order_testing(get_rates = true, no_categories = false, shippo_enabled = true, insurance_enabled = false)
    shippo_mock_rates = [
      mock.stubs(provider: 'USPS', servicelevel_name: 'Library Mail', amount: 2.56, object_id: 'ab47a600b2114eb4899cb698731b97ff'),
      mock.stubs(provider: 'USPS', servicelevel_name: 'First-Class Package/Mail Parcel', amount: 4.58, object_id: 'adf6939b914a46f1b72882935b7244be')
    ]

    if shippo_enabled
      Spree::Product.any_instance.expects('shippo_enabled?').at_least(0).returns(true)
      Spree::Product.any_instance.expects('shippo_enabled').at_least(0).returns(true)
    else
      Spree::Product.any_instance.expects('shippo_enabled?').at_least(0).returns(false)
      Spree::Product.any_instance.expects('shippo_enabled').at_least(0).returns(false)
    end

    if insurance_enabled
      Spree::Product.any_instance.expects('insurance_amount').at_least(0).returns(500)
      Spree::Order.any_instance.expects('insurance_enabled?').at_least(0).returns(true)
    end

    Spree::Product.any_instance.expects('user').at_least(0).returns(User.new)

    User.any_instance.expects('name').at_least(0).returns('user name')
    User.any_instance.expects('phone').at_least(0).returns('1231231234')
    User.any_instance.expects('email').at_least(0).returns('user@company.com')
    companies = [Company.new]
    companies.stubs(:reload).returns([Company.new])
    User.any_instance.expects('companies').at_least(0).returns(companies)

    Company.any_instance.expects('name').at_least(0).returns('company name')
    Company.any_instance.expects('street').at_least(0).returns('1 Microsoft Way')
    Company.any_instance.expects('city').at_least(0).returns('Redmond')
    Company.any_instance.expects('state_code').at_least(0).returns('WA')
    Company.any_instance.expects('postcode').at_least(0).returns('98052')
    Company.any_instance.expects('iso_country_code').at_least(0).returns('US')

    if get_rates
      shippo_api_mock = mock
      ignored_params = [:street2, :email, :street_no]
      shippo_api_mock.expects(:get_rates).at_least(1).with do |address_from_info, address_to_info, parcel_info, customs_item_info, customs_declaration_info, insurance|
        check_all_params_not_blank(ShippoApi::ShippoAddressInfo::REQUIRED_PARAMS.reject { |p| ignored_params.include?(p) }, address_from_info) &&
        check_all_params_not_blank(ShippoApi::ShippoAddressInfo::REQUIRED_PARAMS.reject { |p| ignored_params.include?(p) }, address_to_info) &&
        check_all_params_not_blank(ShippoApi::ShippoParcelInfo::REQUIRED_PARAMS, parcel_info) &&
        ((!insurance_enabled && insurance.nil?) || (insurance_enabled && insurance.present?))
      end.returns(shippo_mock_rates)
      ShippoApi::ShippoApi.expects(:new).returns(shippo_api_mock)
    end

    order = FactoryGirl.create(:order_waiting_for_delivery, user: @user, service_fee_amount_guest_cents: 500, currency: 'USD')

    order.line_items.map(&:variant).map(&:shipping_category).uniq.map(&:shipping_methods).flatten.compact.each { |shipping_method| shipping_method.destroy }

    if no_categories
      order.line_items.map(&:variant).map(&:shipping_category).uniq.each { |shipping_category| shipping_category.destroy }
    end

    package = Spree::Shipment.find_by(:order_id => order.id).to_package

    estimator = Spree::Stock::Estimator.new(order)
    shipment = Spree::Shipment.find_by(:order_id => order.id)

    shipping_rates = estimator.shipping_rates(package)
    shipping_rates.each do |shipping_rate|
      shipping_rate.shipment = shipment
      shipping_rate.save!
    end

    order.line_items.map(&:variant).map(&:shipping_category).uniq.each do |shipping_category|
      shipping_category.shipping_methods.reload
      shipping_category.shipping_methods.each do |shipping_method|
        shipping_method.shipping_rates.reload
      end
    end

    order
  end

  context 'shippo' do

    setup do
      FactoryGirl.create(:stripe_payment_gateway)
    end

    should 'create spree shipping methods if shippo enabled' do
      order = setup_stubs_for_shippo_order_testing(true, false, true)

      assert_equal 2, order.line_items.map(&:variant).map(&:shipping_category).uniq.map(&:shipping_methods).flatten.compact.length
      assert_equal 2, order.line_items.map(&:variant).map(&:shipping_category).uniq.map(&:shipping_methods).flatten.compact.map(&:shipping_rates).flatten.compact.length
      assert_equal 2, Spree::Shipment.find_by(:order_id => order.id).shipping_methods.length

      assert order.next

      assert_equal 'payment', order.state
    end

    should 'call get rates with insurance if needed' do
      order = setup_stubs_for_shippo_order_testing(true, false, true, true)

      assert order.next

      assert_equal 'payment', order.state
    end

    should 'not create spree shipping methods if shippo not enabled' do
      order = setup_stubs_for_shippo_order_testing(false, false, false)

      assert_equal 0, Spree::Shipment.find_by(:order_id => order.id).shipping_methods.length

      assert order.next

      assert_equal 'payment', order.state
    end

    should 'create parent shipping category if it does not exist' do
      order = setup_stubs_for_shippo_order_testing(true, true, true)

      order.line_items.map(&:variant).each { |v| v.reload }

      shipping_categories = order.line_items.map(&:variant).map(&:shipping_category).compact.uniq
      assert_operator shipping_categories.length, :>, 0
      shipping_categories.each do |shipping_category|
        assert_match /^Shippo Auto-created .+$/, shipping_category.name
      end
      assert_equal 2, order.line_items.map(&:variant).map(&:shipping_category).uniq.map(&:shipping_methods).flatten.compact.length
      assert_equal 2, order.line_items.map(&:variant).map(&:shipping_category).uniq.map(&:shipping_methods).flatten.compact.map(&:shipping_rates).flatten.compact.length
      assert_equal 2, Spree::Shipment.find_by(:order_id => order.id).shipping_methods.length

      assert order.next

      assert_equal 'payment', order.state
    end

    should 'succeed ordering and purchase shippo rate' do
      shippo_mock_transaction = mock
      shippo_mock_transaction.expects(:object_status).times(2).returns('DONE')
      shippo_mock_transaction.expects(:label_url).returns('http://usps.com/track?id=CG123123')
      shippo_mock_transaction.expects(:tracking_number).returns('CG1234512345')

      Shippo::Transaction.expects(:create).times(1).with do |params|
        params.has_key?(:rate)
      end.returns(shippo_mock_transaction)

      @order = FactoryGirl.create(:order_waiting_for_payment, user: @user, service_fee_amount_guest_cents: 500, currency: 'USD')

      credit_card = stub('valid?' => true)

      @payment_gateway = FactoryGirl.create(:stripe_payment_gateway)
      authorize_response = { token: 'abc', payment_gateway: @payment_gateway }

      ActiveMerchant::Billing::CreditCard.expects(:new).returns(credit_card)

      PaymentGateway.any_instance.expects(:authorize).with do |amount, currency, credit_card|
        amount == Money.new(155_00, 'USD') && credit_card == credit_card
      end.returns(authorize_response)

      credit_card = ActiveMerchant::Billing::CreditCard.new({})

      assert credit_card.valid?
      response = @payment_gateway.authorize(@order.total_amount, 'USD', credit_card)
      assert !response[:error].present?

      @order.create_billing_authorization(
          token: response[:token],
          payment_gateway: @payment_gateway,
          payment_gateway_mode: PlatformContext.current.instance.test_mode? ? "test" : "live"
      )
      p = @order.payments.create(amount: @order.total_amount, company_id: @order.company_id)

      shipping_category = Spree::ShippingCategory.create!(
        :name => 'Default',
        :instance_id => @order.instance
      )

      shipping_method = Spree::ShippingMethod.create!(
        :name => 'USPS Parcel Select',
        :instance_id => @order.instance_id,
        :order_id => @order.id,
        :precalculated_cost => 25.50,
        :shippo_rate_id => 'abc123',
        :shipping_categories => [shipping_category],
        :calculator => Spree::Calculator::Shipping::PrecalculatedCostCalculator.new,
      )

      shipping_rate = Spree::ShippingRate.new
      shipping_rate.shipment = Spree::Shipment.find_by(:order_id => @order.id)
      shipping_rate.shipping_method = shipping_method
      shipping_rate.selected = true
      shipping_rate.cost = shipping_method.precalculated_cost
      shipping_rate.instance_id = @order.instance_id
      shipping_rate.save!

      assert_nil shipping_method.order.shippo_rate_purchased_at
      assert_equal nil, shipping_method.shippo_tracking_number
      assert_equal nil, shipping_method.shippo_label_url

      @order.next

      @order.reload
      shipping_method.reload

      assert_not_nil shipping_method.order.shippo_rate_purchased_at
      assert_kind_of Time, shipping_method.order.shippo_rate_purchased_at
      assert_equal 'CG1234512345', shipping_method.order.shipments.first.shippo_tracking_number
      assert_equal 'http://usps.com/track?id=CG123123', shipping_method.order.shipments.first.shippo_label_url

      payment = @order.reload.payments.first
      assert_not_nil payment
      assert_equal 155, payment.amount.to_i
      assert_equal 'USD', payment.currency
      assert_equal @order.company_id, payment.company_id
      assert_equal @order.instance_id, payment.instance_id
      assert_equal 'complete', @order.state
      assert_not_nil @order.billing_authorization
      assert_equal 'abc', @order.billing_authorization.token
      assert_equal @payment_gateway.id, @order.billing_authorization.payment_gateway_id
    end
  end
end
