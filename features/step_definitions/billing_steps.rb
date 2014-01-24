Then /^#{capture_model} should have a billing profile$/ do |user_instance|
  instance_client = InstanceClient.last
  assert instance_client.stripe_id.present? || instance_client.paypal_id.present?, "No stripe_id nor paypal_id present for: #{instance_client.inspect}"
  assert_equal  model!(user_instance).id, instance_client.client_id
  assert_equal 'User', instance_client.client_type
end
