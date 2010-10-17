
Then /^I should see the following workplaces in order:$/ do |table|
  found = all("article.workplace h3")
  table.raw.flatten.each_with_index do |workplace, index|
    found[index].text.should == workplace
  end
end

Then /^I should see the creators gravatar/ do
  page.should have_css(".creator img")
end

