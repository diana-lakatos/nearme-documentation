Then(/^I should see partners list$/) do
  Partner.all.each do |partner|
    page.should have_content(partner.name)
  end
end

Given(/^#{capture_model} has theme with images$/) do |model|
  @instance = model!(model)
  @theme = @instance.theme
  %w(logo_image logo_retina_image icon_image icon_retina_image hero_image).each do |image_attr|
    image_path = "http://www.example.com/#{image_attr}.jpg"
    stub_image_url(image_path)
    @theme.stubs("#{image_attr}_url").returns(image_path)
  end
end

When(/^I navigate to new partner form$/) do
  Instance.any_instance.stubs(:theme).returns(@theme)
  click_link "New Partner" 
end

When(/^I fill partner form with valid details (with|without) theme$/) do |theme_included|
  fill_in 'partner_name', with: 'Test partner'
  fill_in 'partner_domain_attributes_name', with: 'dnm.local'
  if theme_included == 'with'
    fill_in 'partner_theme_attributes_name', with: 'theme name'
  end
end

Then(/^I should see created partner show page$/) do
  page.should have_content('Partner was successfully created.')
  page.should have_content('Test partner')
  page.should have_content('dnm.local')
end

Then(/^I see a partner form with prefilled values$/) do
  assert_equal @instance.theme.site_name, page.find(:css, '#partner_theme_attributes_site_name').value
end

Then(/^Images from instance theme should be copied to partner's theme$/) do
  partner = Partner.last 
  assert_not_equal partner.theme, partner.instance.theme
  %w(logo_image logo_retina_image icon_image icon_retina_image hero_image).each do |image_attr|
    assert partner.theme.send("#{image_attr}_url").try(:include?, image_attr), "Partner theme should have #{image_attr} in '#{partner.theme.send("#{image_attr}_url")}'"
  end
end

Then(/^Partner should not have its own theme$/) do
  assert !Partner.last.has_theme?
end
