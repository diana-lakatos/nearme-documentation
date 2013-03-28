When /^I freeze time$/ do
  Timecop.freeze Time.now
end

After do
  Timecop.return
end

