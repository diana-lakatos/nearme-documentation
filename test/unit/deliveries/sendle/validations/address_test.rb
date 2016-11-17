# frozen_string_literal: true
require 'test_helper_lite'
require 'active_model'
# require './app/models/deliveries'
require './app/models/deliveries/validations'
require './app/models/deliveries/sendle/validations/address'
require 'pry'
require 'date'

class MyAddress
  include ActiveModel::Validations

  attr_accessor :city, :country, :postcode, :address
end

class Deliveries::Sendle::Validations::AddressTest < ActiveSupport::TestCase
  def validator
    Deliveries::Sendle::Validations::Address.new
  end

  test 'general validations' do
    address = MyAddress.new

    validator.validate(address)

    assert address.errors.added?(:address, :blank)
    assert address.errors.added?(:city, :blank)
    assert address.errors.added?(:postcode, :blank)
    assert address.errors.added?(:country, :blank)
  end

  test 'all good' do
    valid_au_addresses.each do |address|
      validator.validate(address)

      assert_equal address.errors.messages, {}, format('Address failed: %s', address.address)
    end
  end

  test 'wrong pickup place' do
    address = MyAddress.new
    address.address = 'Ethelton 15015 NZ'
    address.city = 'Ethelton'
    address.country = 'New Zealand'
    address.postcode = '15015'

    validator.validate(address)

    assert address.errors.added?(:address, :invalid_pickup_location)
  end

  private

  def au_addresses
    [
      'Potts Point               | 2011     | Australia | Sydney, 152 Victoria Street, Potts Point, New South Wales, Australia',
      'Browns Plains             | 4118     | Australia | 748-750 Wembley Rd, Browns Plains, QLD, 4118, Australia',
      'Ashfield                  | 2131     | Australia | 73 Milton Street, Ashfield, New South Wales, Australia',
      'Saint Leonards            | 2065     | Australia | 1, Sergeants Lane, Saint Leonards, New South Wales, Australia',
      'Maroubra                  | 2035     | Australia | Maroubra, New South Wales, Australia',
      'Camperdown                | 2050     | Australia | 16-22 Australia St, Camperdown NSW 2050, Australia',
      'Red Hill                  | 2603     | Australia | 3 Nuyts St, Red Hill ACT 2603, Australia',
      'Harris Park               | 2150     | Australia | 2-6, Kendall St, Harris Park, NSW, Australia',
      'Coogee                    | 2034     | Australia | 90 Mount Street, Coogee, New South Wales, Australia',
      'Lane Cove                 | 2066     | Australia | Grace St, Lane Cove NSW 2066, Australia',
      'Wentworthville            | 2145     | Australia | Wentworthville Station, Wentworthville, New South Wales, Australia',
      'Rushcutters Bay           | 2011     | Australia | 2, Kurraghein Avenue, Rushcutters Bay, New South Wales, Australia',
      'Melbourne                 | 3000     | Australia | 283, Spring Street, Melbourne, Victoria, Australia',
      'Ultimo                    | 2007     | Australia | 558 Jones Street, Ultimo, NSW, Australia',
      'Saint Kilda               | 3182     | Australia | 416 St Kilda Road, Saint Kilda, Victoria, Australia',
      'Surry Hills               | 2010     | Australia | 74/76 Campbell St, Surry Hills NSW 2010, Australia',
      'Camperdown                | 2050     | Australia | 55-57 Denison St, Camperdown NSW 2050, Australia'
    ].map { |row| row.split('|').map(&:strip) }
  end

  def valid_au_addresses
    au_addresses.map do |city, postcode, country, full_address|
      MyAddress.new.tap do |address|
        address.address = full_address
        address.city = city
        address.country = country
        address.postcode = postcode
      end
    end
  end
end
