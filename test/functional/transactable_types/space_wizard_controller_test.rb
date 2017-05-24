# frozen_string_literal: true
require 'test_helper'
require 'vcr_setup'

class TransactableTypes::SpaceWizardControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)

    sign_in @user
    FactoryGirl.create(:location_type)
    @partner = FactoryGirl.create(:partner)

    @transactable_type = FactoryGirl.create(:transactable_type_listing)
  end

  context 'scopes current partner for new company' do
    should 'match partner_id' do
      PlatformContext.current = PlatformContext.new(@partner)
      @user = FactoryGirl.create(:user)
      sign_in @user
      stub_us_geolocation
      assert_difference 'Transactable.count' do
        post :submit_listing, get_params
      end
      @company = Company.last
      assert_equal @partner.id, @company.partner_id
    end
  end

  should 'set correct foreign keys' do
    stub_us_geolocation
    assert_difference 'Transactable.count' do
      post :submit_listing, get_params
    end
    @company = Company.last
    instance_id = @company.instance_id
    creator_id = @company.creator_id
    @company.locations.each do |location|
      assert_equal instance_id, location.instance_id
      assert_equal creator_id, location.creator_id
      location.listings.each do |_listing|
        assert_equal instance_id, location.instance_id
        assert_equal creator_id, location.creator_id
      end
    end
  end

  context 'price must be formatted' do
    should 'be able to handle 1 to 1 unit to subunit conversion date passed manually' do
      stub_us_geolocation
      assert_difference('Transactable.count', 1) do
        post :submit_listing, get_params(prices: { '1_day': '25' }, currency: 'JPY')
      end
      @listing = assigns(:user).listings.first
      assert_equal 25.to_money('JPY'), @listing.action_type.price_for('1_day')
      assert_equal 25, @listing.action_type.price_cents_for('1_day')
    end

    should 'be able to handle 5 to 1 unit to subunit conversion date passed manually' do
      stub_us_geolocation
      assert_difference('Transactable.count', 1) do
        post :submit_listing, get_params(prices: { '1_day': '25' }, currency: 'MGA')
      end
      @listing = assigns(:user).listings.first
      assert_equal 25.to_money('MGA'), @listing.action_type.price_for('1_day')
      assert_equal 125, @listing.action_type.price_cents_for('1_day')
    end

    should 'be able to handle 5 to 1 unit to subunit conversion if it is default currency' do
      stub_us_geolocation
      PlatformContext.current.instance.update_attribute(:default_currency, 'MGA')
      assert_difference('Transactable.count', 1) do
        post :submit_listing, get_params(prices: { '1_day': '25' }, currency: '')
      end
      @listing = assigns(:user).listings.first
      assert_equal 25.to_money('MGA'), @listing.action_type.price_for('1_day')
      assert_equal 125, @listing.action_type.price_cents_for('1_day')
    end

    should 'not create with invalid characters in price' do
      stub_us_geolocation
      assert_difference('Transactable.count', 0) do
        post :submit_listing, get_params(prices: { '7_day': '!@#$%^&*()_+=_:;"[]}{\,<.>/?`~', '30_day': 'i am not valid price I guess' })
      end
      @user = assigns(:user)
      assert @user.first_listing.errors['action_types.pricings'].present?
      refute @user.first_listing.persisted?
    end

    should 'handle nil and empty prices' do
      stub_us_geolocation
      assert_difference('Transactable.count', 1) do
        post :submit_listing, get_params(prices: { '1_day': nil, '7_day': '', '30_day': '249.00' })
      end
      @listing = assigns(:user).listings.first
      assert_nil @listing.action_type.price_for('1_day')
      assert_nil @listing.action_type.price_cents_for('7_day')
      assert_equal 24_900, @listing.action_type.price_cents_for('30_day')
    end

    should 'not raise exception if hash is incomplete' do
      assert_no_difference('Transactable.count') do
        post :submit_listing, transactable_type_id: @transactable_type.id, 'user' => { 'companies_attributes' => { '0' => { 'name' => 'International Secret Intelligence Service' } } }
      end
    end
  end

  context 'geo-located default country' do
    setup do
      @user.country_name = nil
      @user.save!
    end

    should 'be set to Greece' do
      VCR.use_cassette 'freegeoip_greece' do
        FactoryGirl.create(:country, name: 'Greece', iso: 'GR')
        # Set request ip to an ip address in Greece
        @request.env['REMOTE_ADDR'] = '2.87.255.255'
        get :list, transactable_type_id: @transactable_type.id
        assert assigns(:country) == 'Greece'
        assert_select 'option[value="Greece"][selected="selected"]', 1
      end
    end

    should 'be set to Brazil' do
      VCR.use_cassette 'freegeoip_brazil' do
        FactoryGirl.create(:country, name: 'Brazil', iso: 'BR')
        # Set request ip to an ip address in Brazil
        @request.env['REMOTE_ADDR'] = '139.82.255.255'
        get :list, transactable_type_id: @transactable_type.id
        assert assigns(:country) == 'Brazil'
        assert_select 'option[value="Brazil"][selected="selected"]', 1
      end
    end
  end

  context 'GET new' do
    should 'redirect to manage listings page if has listings' do
      create_listing
      get :new, transactable_type_id: @transactable_type.id
      assert_redirected_to dashboard_company_transactable_type_transactables_path(@transactable_type.slug)
    end

    should 'redirect to new location if no listings' do
      create_listing
      @location.destroy
      get :new, transactable_type_id: @transactable_type.id
      assert_redirected_to dashboard_company_transactable_type_transactables_path(@transactable_type.slug)
    end

    should 'redirect to new listing if no listings but with one location' do
      create_listing
      @listing.destroy
      get :new, transactable_type_id: @transactable_type.id
      assert_redirected_to dashboard_company_transactable_type_transactables_path(@transactable_type.slug)
    end

    should 'redirect to dashboard if no listings but more than one location' do
      create_listing
      @listing.destroy
      FactoryGirl.create(:location, company: @company)
      get :new, transactable_type_id: @transactable_type.id
      assert_redirected_to dashboard_company_transactable_type_transactables_path(@transactable_type.slug)
    end

    should 'redirect to space wizard list if no listings' do
      get :new, transactable_type_id: @transactable_type.id
      assert_redirected_to transactable_type_space_wizard_list_url(@transactable_type)
    end

    should 'redirect to registration path if not logged in' do
      sign_out @user
      get :new, transactable_type_id: @transactable_type.id
      assert_redirected_to new_api_user_url(return_to: transactable_type_space_wizard_list_url(@transactable_type))
    end
  end

  context 'with multiple sections' do
    should 'render all sections correctly' do
      FactoryGirl.create(:form_component, form_componentable: @transactable_type, form_fields: [{ 'company' => 'name' }, { 'company' => 'address' }, { 'location' => 'name' }], name: 'Super Cool Section 1')
      FactoryGirl.create(:form_component, form_componentable: @transactable_type, form_fields: [{ 'transactable' => 'price' }, { 'transactable' => 'photos' }, { 'transactable' => 'name' }], name: 'Transactable Section')
      FactoryGirl.create(:form_component, form_componentable: @transactable_type, form_fields: [{ 'user' => 'phone' }], name: 'Contact Information')
      get :list, transactable_type_id: @transactable_type.id
      assert_select 'h2', 'Super Cool Section 1'
      assert_select 'h2', 'Transactable Section'
      assert_select 'h2', 'Contact Information'
      assert_select '#user_phone'
    end
  end

  context 'with skip_company' do
    setup do
      @instance_with_skip_company = FactoryGirl.create(:instance, skip_company: true)
      @domain = FactoryGirl.create(:domain, target: @instance_with_skip_company)

      PlatformContext.current = PlatformContext.new(@instance_with_skip_company)
      @user = FactoryGirl.create(:user)
      sign_in @user
      @transactable_type = FactoryGirl.create(:transactable_type_listing)

      @params_without_company_name = get_params
      @params_without_company_name['user']['companies_attributes']['0'].delete('name')
    end

    should 'create listing when location skip_company is set to true' do
      stub_us_geolocation
      assert_difference('Transactable.count', 1) do
        post :submit_listing, @params_without_company_name
      end
    end

    should 'create listing when location skip_company is set to true and address is missing' do
      stub_us_geolocation
      @params_without_company_name['user']['companies_attributes']['0'].delete('company_address_attributes')

      assert_difference('Transactable.count', 1) do
        post :submit_listing, @params_without_company_name
      end

      company = Company.last
      assert_equal company.latitude, 37.09024
      assert_equal company.longitude, -95.712891
    end

    context 'with skip_location' do
      setup do
        @transactable_type.update_attribute :skip_location, true
      end

      should 'create listing when location skip_company is set to true and address is missing' do
        stub_us_geolocation

        @params_without_company_name['user']['companies_attributes']['0'].delete('company_address_attributes')

        assert_difference('Location.count', 1) do
          post :submit_listing, @params_without_company_name
        end

        company = Company.last
        location = Location.last
        assert_equal 37.09024, company.latitude
        assert_equal -95.712891, company.longitude
        assert_equal 5, location.latitude
        assert_equal 8, location.longitude
      end

      should 'create listing with company address when location skip_company and skip_listing set' do
        stub_us_geolocation
        @params_without_company_name['user']['companies_attributes']['0'].delete('company_address_attributes')
        @params_without_company_name['user']['companies_attributes']['0']['locations_attributes']['0'].delete('location_address_attributes')

        assert_difference('Location.count', 1) do
          post :submit_listing, @params_without_company_name
        end
      end
    end
  end

  private

  def get_params(options = {})
    options.reverse_merge!(currency: 'USD')
    { 'user' =>
     { 'companies_attributes' => { '0' =>
       {
         'name' => 'International Secret Intelligence Service',
         'company_address_attributes' => {
           'address' => 'Poznań, Polska',
           'latitude' => '52.406374',
           'longitude' => '16.925168100000064'
         },
         'locations_attributes' => { '0' => {
           'description' => 'Our historic 11-story Southern Pacific Building, also known as "The Landmark", was completed in 1916. We are in the 172 m Spear Tower.',
           'name' => 'Location',
           'location_type_id' => '1',
           'location_address_attributes' =>
            {
              'address' => 'usa',
              'local_geocoding' => '10',
              'latitude' => '5',
              'longitude' => '8',
              'formatted_address' => 'formatted usa'
            },
           'listings_attributes' => { '0' => {
             'transactable_type_id' => TransactableType.first.id,
             'name' => 'Desk',
             'description' => 'We have a group of several shared desks available.',
             'action_hourly_booking' => false,
             'quantity' => '1',
             'booking_type' => options[:booking_type] || 'regular',
             'confirm_reservations' => '0',
             'photos_attributes' => [FactoryGirl.attributes_for(:photo)],
             'currency' => options[:currency],
             'properties' => {
               'listing_type' => 'Desk'
             }
           }.merge(action_type_attibutes(options)) }
         } }
       } },
       'country_name' => 'United States',
       'phone' => '123456789' },
      transactable_type_id: @transactable_type.id }
  end

  def create_listing
    @company = FactoryGirl.create(:company, creator: @user)
    @location = FactoryGirl.create(:location, company: @company)
    @listing = FactoryGirl.create(:transactable, location: @location)
  end
end
