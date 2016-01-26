When /^I travel to early morning$/ do
  travel_to Time.zone.today.beginning_of_day
end

When /I travel to time (.*?)$/ do |time|
  travel_to Chronic.parse(time)
end


