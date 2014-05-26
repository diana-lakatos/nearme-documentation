Then /^#{capture_model} should have a billing profile$/ do |user_instance|
  reservation = Reservation.last
  assert reservation.billing_authorization.token.present?
  assert reservation.billing_authorization.payment_gateway_class.present?
end
