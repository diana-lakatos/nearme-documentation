And /^I should see translation for "(.*)":$/ do |key, interpolations|
  h = {}
  interpolations.hashes.each { |el| h[el["Variable"].to_sym] = el["Value"] }
  page.should have_content I18n.t(key,h)
end

And /^I should see translation for "(.*)"$/ do |key|
  page.should have_content I18n.t(key)
end
