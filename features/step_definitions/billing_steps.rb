Then /^reservation should have billing authorization token$/ do
  reservation = Reservation.last
  assert reservation.billing_authorization.token.present?
  assert reservation.billing_authorization.payment_gateway_class.present?
end

Then /^#{capture_model} should have a billing profile$/ do |user|
  user = model!(user)
  assert user.instance_clients.first.present?
  assert_equal 'customer_1', user.instance_clients.first.customer_id
  assert_equal 'card_1', user.instance_clients.first.credit_cards.first.token
end
