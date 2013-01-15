Stripe.api_key, STRIPE_PUBLIC_KEY = if Rails.env.production?
  ["sk_live_YJet2CBSWgQ2UeuvQiG0vKEC", "pk_live_h3zjCFhi02B4c9juuzmFOe3n"]
elsif Rails.env.development? || Rails.env.staging?
  ["sk_test_lpr4WQXQdncpXjjX6IJx01W7", "pk_test_iCGA8nFZdILrI1UtuMOZD2aq"]
else
  # Don't setup stripe keys in Test environment
end
