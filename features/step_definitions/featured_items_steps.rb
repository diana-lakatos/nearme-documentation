Given(/^homepage content has featured_items tag with target: "(.*?)"$/) do |target|
  InstanceView.create(
  	path: "home/homepage_content",
  	format: "html",
  	handler: "liquid",
  	body: "{% featured_items target: #{target} %}",
  	partial: true,
  	instance_id: PlatformContext.current.instance.id,
  	locales: [Locale.first]
  )
end

Then(/^I should be able to see ajax call for "(.*?)"$/) do |target|
  assert_includes page.body, "/featured_items/?target=#{target}&amount"
end
