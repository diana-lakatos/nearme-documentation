Given(/^some listings exists$/) do
  3.times { FactoryGirl.create(:listing_in_adelaide) }
end

When(/^search settings are mixed individual listing$/) do
  @instance = PlatformContext.current.instance
  @instance.default_search_view = 'listing_mixed'
  @instance.searcher_type = 'geo'
  @instance.search_engine = 'postgresql'

  @instance.save!
end

Then(/^I should be able to see three locations$/) do
  assert_equal 3, page.all("article.location").count
end

And(/^I should be able to see three listings$/) do
   assert_equal 3, page.all("article.location > .tabbable .title .listing").count
end
