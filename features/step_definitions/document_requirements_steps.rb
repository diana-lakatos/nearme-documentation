And /^Fill in document requirement fields$/ do
  fill_in_document_requirement_form("transactable", "0")
end

And /^Fill in form for another document requirement$/ do
  fill_in_document_requirement_form("transactable", "1")
end

And /^Show form for another document requirement$/ do
  find('.document-requirements .add-new').click
  page.should have_css('.remove-document-requirement')
end

And /^Fill in document requirement fields for product$/ do
  fill_in_document_requirement_form("product_form", "0")
end

And /^Fill in form for another document requirement for product$/ do
  fill_in_document_requirement_form("product_form", "1")
end

And /^Document requirement for transactable exists$/ do
  @document_requirement = FactoryGirl.create(:document_requirement, 
    label: "Passport", description: "Provide your passport", item: listing)
end

And /^Visit edit listing page$/ do
  visit edit_dashboard_company_transactable_type_transactable_path(listing.transactable_type, listing)
end

And /^Visit edit product page$/ do
  visit edit_dashboard_company_product_type_product_path(@product.product_type, @product)
end

And /^Updated document requirement should be present in form$/ do
  assert_document_requirement_data("transactable")
end

And /^Updated document requirement should be present in product form$/ do
  assert_document_requirement_data("product_form")  
end

And /^Two document requirements should be present in form$/ do
  page.should have_css('.document-requirement', count: 2)
end

Given /^Product and document requirement for it exist$/ do
  @product = FactoryGirl.create(:base_product, company: user.companies.first, user: user, product_type: user.instance.product_types.first)
  @document_requirement = FactoryGirl.create(:document_requirement, item: @product)
end

When /^I edit first product$/ do
  visit edit_dashboard_company_product_type_product_path(@product.product_type, @product)
end

And /^document upload enabled$/ do
  mandatory_requirement = DocumentsUpload::REQUIREMENTS[0]
  @enabled_documents_upload = FactoryGirl.create(:enabled_documents_upload, requirement: mandatory_requirement)
end

def fill_in_document_requirement_form(form, number)
  fill_in "#{form}_document_requirements_attributes_#{number}_label", with: "ID"
  fill_in "#{form}_document_requirements_attributes_#{number}_description", with: "Add your ID"
end

def assert_document_requirement_data(form)
  @document_requirement.reload
  find_field("#{form}_document_requirements_attributes_0_label").value.should eq @document_requirement.label
  find_field("#{form}_document_requirements_attributes_0_description").value.should eq @document_requirement.description
end
