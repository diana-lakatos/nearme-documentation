Then /^#{capture_model} should have a billing profile$/ do |user_instance|
  instance_client = model!(user_instance).reload.instance_clients.first
  assert instance_client.stripe_id.present? || instance_client.paypal_id.present?, "No stripe_id nor paypal_id present for: #{instance_client.inspect}"
end
