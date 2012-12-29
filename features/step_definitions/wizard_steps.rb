Then /^I should be at the "(.*)" step$/ do |step_name|
  assert page.has_css?('.box > ul.space-wizard > li.current > span', :content => step_name)
end
