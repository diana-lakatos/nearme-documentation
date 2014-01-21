Then /^#{capture_model} should have a billing profile$/ do |user_instance|
  user = model!(user_instance).reload
  assert user.stripe_id.present? || user.paypal_id.present?, "No stripe_id nor paypal_id present for: #{user_instance.inspect}"
end
