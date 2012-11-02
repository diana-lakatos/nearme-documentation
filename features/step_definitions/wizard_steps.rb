Then /^I should be at the "(.*)" step$/ do |step_name|
  assert page.has_css?('.box > h2 > ul > li.current > span', :content => step_name)
end
