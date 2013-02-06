Then /^#{capture_model} should have a billing profile$/ do |user_instance|
  assert model!(user_instance).reload.stripe_id.present?, "No stripe_id present for: #{user_instance.inspect}"
end