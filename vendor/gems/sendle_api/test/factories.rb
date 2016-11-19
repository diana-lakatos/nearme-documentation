# frozen_string_literal: true
require 'date'

module Factories
  def sender_params(contact: contact_params,
                    address: address_params,
                    instructions: 'Knock loudly')
    {
      contact: contact,
      address: address,
      instructions: instructions
    }
  end

  def address_params(address_line1: '123 Gotham Ln', suburb: 'Sydney',
                     state_name: 'NSW', postcode: '2000',
                     country: 'Australia')
    {
      address_line1: address_line1,
      suburb: suburb,
      state_name: state_name,
      postcode: postcode,
      country: country
    }
  end

  def contact_params(name: 'Clark Kent', email: 'clarkissuper@dailyplanet.xyz')
    {
      name: name,
      email: email
    }
  end

  def receiver_params
    {
      contact: contact_params,
      address: address_params(address_line1: '80 Wentworth Park Road', suburb: 'Glebe',
                              state_name: 'NSW',
                              postcode: '2037',
                              country: 'Australia'),
      instructions: 'Give directly to Clark'
    }
  end

  def order_params(sender: sender_params, receiver: receiver_params)
    {
      sender: sender,
      receiver: receiver,
      pickup_date:  tomorrow,
      description:  'Kryptonite',
      kilogram_weight: 1,
      cubic_metre_volume:  0.01,
      customer_reference:  'SupBdayPressie',
      metadata: {
        your_data: 'XYZ123'
      }
    }
  end

  def tomorrow
    Date.today + 1
  end
end
