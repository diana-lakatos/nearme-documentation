Given /^I am adding new product$/ do
  visit new_dashboard_company_product_type_product_path(PlatformContext.current.instance.product_types.first)
end

Given /^a shipping profile exists$/ do
  create_first_shipping_profile
end

And /^I fill products form with valid details$/  do
  fill_product_form
end

And /^I submit the product form$/  do
  page.execute_script("$('form#product_form').submit()")
end

Then /^Product with my details should be created$/  do
  product = Spree::Product.last
  assert_product_data(product)
end

Given /^the product type$/ do
  FactoryGirl.create(:product_type)
end

Given(/^I am browsing bulk upload products$/) do
  visit dashboard_company_product_type_products_path(Spree::ProductType.last)
end

When /^I upload csv file with products$/ do
  Utils::DefaultAlertsCreator::DataUploadCreator.new.notify_uploader_of_finished_import_email!
  find(:css, 'a.bulk-upload').click
  stub_image_url('http://www.example.com/image1.jpg')
  stub_image_url('http://www.example.com/image2.jpg')
  work_in_modal do
    page.should have_css('#new_data_upload')
    check('data_upload_options_sync_mode')
    attach_file('data_upload_csv_file', File.join(Rails.root, *%w[test assets data_importer products current_data.csv]))
    find('.btn-toolbar input[type=submit]').click
  end
  page.should_not have_css('#new_data_upload')
end

Then /^New products from csv should be added$/ do
  user = model!('user')
  assert_equal ['product 1', 'product 2'], user.products.pluck(:name).sort
end
