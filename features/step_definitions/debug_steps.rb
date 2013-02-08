When /^I eval: (.*)$/ do |ruby|
  p eval(ruby)
end

When /^I open page$/ do
  save_and_open_page
end

