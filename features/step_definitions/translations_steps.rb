# This was built by Maciek to be able to use Translation Keys instead of hard coded text to make it more high level. This will help with testing foreign MPs in the future.

And /^I should see translation for "(.*)":$/ do |key, interpolations|
  h = {}
  interpolations.hashes.each { |el| h[el["Variable"].to_sym] = el["Value"] }
  page.should have_content I18n.t(key,h)
end