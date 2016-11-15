require './lib/sendle_api'

# puts SendleApi::Client.new.ping.inspect

def quote(params)
  puts SendleApi::Client.new.get_quote(params).inspect
end

# quote 'pickup_suburb' => 'Altona East', 'pickup_postcode' => '3025', 'delivery_suburb' => 'Dendy', 'delivery_postcode' => 3186, 'kilogram_weight' => 2

# quote 'pickup_postcode' => '4275', 'pickup_suburb' => 'Wonglepong', 'delivery_suburb' => 'Foul Bay', 'delivery_postcode' => '5577', 'cubic_metre_volume' => '0.01', 'kilogram_weight' => '25'

def place_order(params)
  return
  SendleApi::Client.new.place_order(params)
end

o = place_order 'pickup_date' =>  '2016-10-10',
             'description' =>  'Kryptonite',
             'kilogram_weight' => 1,
             'cubic_metre_volume' =>  0.01,
             'customer_reference' =>  'SupBdayPressie',
             'metadata' => {
               'your_data' => 'XYZ123'
             },
             'sender' => {
               'contact' => {
                 'name' => 'Lex Luthor',
                 'phone' => '0412 345 678'
               },
               'address' => {
                 'address_line1' =>  '123 Gotham Ln',
                 'suburb' =>  'Sydney',
                 'state_name' => 'NSW',
                 'postcode' => '2000',
                 'country' => 'Australia'
               },
               'instructions' => 'Knock loudly'
             },
             'receiver' => {
               'contact' => {
                 'name' => 'Clark Kent',
                 'email' => 'clarkissuper@dailyplanet.xyz'
               },
               'address' => {
                 'address_line1' => '80 Wentworth Park Road',
                 'suburb' =>  'Glebe',
                 'state_name' => 'NSW',
                 'postcode' => '2037',
                 'country' => 'Australia'
               },
               'instructions' => 'Give directly to Clark'
             }

# puts o.inspect

o = {"order_id"=>"764a637b-c3d9-42f6-b87f-24db4de57343"}
o = SendleApi::Client.new.view_order(o['order_id'])
puts o.inspect
puts SendleApi::Client.new.track_parcel(sendle_reference: o.body['sendle_reference']).inspect
# puts SendleApi::Client.new.cancel_order(o.body['order_id']).inspect
