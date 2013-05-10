if Rails.env.production?
  list_id = "29230a6fdb"
  api_key = "1d8830aa022696730ba3100220e07038-us5"
else
  list_id = "3be1e89427"
  api_key = "6f9adc1d2924112f3c27494daa4a5e4e-us4"
end
Gibbon.api_key = api_key
Gibbon.timeout = 15
Gibbon.throws_exceptions = false
MAILCHIMP = Mailchimp.new(Gibbon.new, list_id)
