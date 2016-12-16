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

  attr_accessor :city, :country, :postcode, :address, :state, :suburb
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
    assert address.errors.added?(:state, :blank)
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
      'Potts Point               | New South Wales              | 2011     | Australia | Sydney, 152 Victoria Street, Potts Point, New South Wales, Australia
       Browns Plains             | Queensland                   | 4118     | Australia | 748-750 Wembley Rd, Browns Plains, QLD, 4118, Australia
       Ashfield                  | New South Wales              | 2131     | Australia | 73 Milton Street, Ashfield, New South Wales, Australia
       Saint Leonards            | New South Wales              | 2065     | Australia | 1, Sergeants Lane, Saint Leonards, New South Wales, Australia
       Maroubra                  | New South Wales              | 2035     | Australia | Maroubra, New South Wales, Australia
       Camperdown                | New South Wales              | 2050     | Australia | 16-22 Australia St, Camperdown NSW 2050, Australia
       Glebe                     | New South Wales              | 2037     | Australia | 4/14 Leichhardt St, Glebe, NSW, 2037, Australia
       Red Hill                  | Australian Capital Territory | 2603     | Australia | 3 Nuyts St, Red Hill ACT 2603, Australia
       Harris Park               | New South Wales              | 2150     | Australia | 2-6, Kendall St, Harris Park, NSW, Australia
       Kensington                | New South Wales              | 2033     | Australia | Lorne Ave, Kensington NSW 2033, Australia
       Wolli Creek               | New South Wales              | 2205     | Australia | 18-26, Allen Street, Wolli Creek, New South Wales, Australia
       Croydon North             | Victoria                     | 3136     | Australia | 4 Hurst Court, Croydon North, Victoria, Australia
       Turrella                  | New South Wales              | 2205     | Australia | 10, Alexandra St, Turrella, New South Wales, Australia
       Coogee                    | New South Wales              | 2034     | Australia | 90 Mount Street, Coogee, New South Wales, Australia
       South Yarra               | Victoria                     | 3141     | Australia | 11-17 Daly Street, SouthYarra, melbourne 3141.
                                 | Queensland                   |          | Australia | Cairns, Queensland, Australia
       Wentworthville            | New South Wales              | 2145     | Australia | Wentworthville Station, Wentworthville, New South Wales, Australia
       Rushcutters Bay           | New South Wales              | 2011     | Australia | 2, Kurraghein Avenue, Rushcutters Bay, New South Wales, Australia
       Mosman                    | New South Wales              | 2088     | Australia | 100 Spit Rd, Mosman, New South Wales, Australia
       Melbourne                 | Victoria                     | 3000     | Australia | 283, Spring Street, Melbourne, Victoria, Australia
       Ultimo                    | New South Wales              | 2007     | Australia | 558 Jones Street, Ultimo, NSW, Australia
       Saint Kilda               | Victoria                     | 3182     | Australia | 416 St Kilda Road, Saint Kilda, Victoria, Australia
       Lane Cove                 | New South Wales              | 2066     | Australia | Grace St, Lane Cove NSW 2066, Australia
       Surry Hills               | New South Wales              | 2010     | Australia | 74/76 Campbell St, Surry Hills NSW 2010, Australia'
    ].map { |row| row.split('|').map(&:strip) }
  end

  def valid_au_addresses
    au_addresses.map do |city, state, postcode, country, full_address|
      MyAddress.new.tap do |address|
        address.address = full_address
        address.city = city
        address.state = state
        address.country = country
        address.postcode = postcode
      end
    end
  end
end
