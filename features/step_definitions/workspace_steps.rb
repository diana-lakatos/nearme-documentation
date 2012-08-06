
Then /^I should see the following listings in order:$/ do |table|
  found = all("article.listing h2")
  table.raw.flatten.each_with_index do |listing, index|
    found[index].text.should == listing
  end
end

Then /^I should see the creators gravatar/ do
  page.should have_css(".creator img")
end

