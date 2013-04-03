Given /^I freeze time at (.*?)$/ do |time|
  Timecop.freeze Chronic.parse(time) 
end

When /^I unfreeze time$/ do
  Timecop.return
end