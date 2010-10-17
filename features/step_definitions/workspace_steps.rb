Then /^I should see the following workplaces in order:$/ do |table|
  found = all("div.workplace h3")
  table.raw.flatten.each_with_index do |workplace, index|
    found[index].text.should == workplace
  end
end
