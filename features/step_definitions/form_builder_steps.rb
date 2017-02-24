# frozen_string_literal: true
When(/^Form builder configuration is in place$/) do
  MarketplaceBuilder::Loader.load('test/assets/dummy_marketplace',
                                  verbose: false,
                                  instance_id: PlatformContext.current.instance.id,
                                  creators: [
                                    MarketplaceBuilder::Creators::MarketplaceCreator,
                                    MarketplaceBuilder::Creators::TransactableTypesCreator,
                                    MarketplaceBuilder::Creators::InstanceProfileTypesCreator,
                                    MarketplaceBuilder::Creators::CategoriesCreator,
                                    MarketplaceBuilder::Creators::CustomModelTypesCreator
                                  ])
  FormComponentToFormConfiguration.new(Instance.where(id: PlatformContext.current.instance.id)).go!
end

When(/^I update my profile and trigger all validation errors$/) do
  page.find('a[data-association="Everything Model"]').click
  click_button 'Save'
end

Then(/^All error messages for the form are correctly displayed$/) do
  page.should have_content "Avatar can't be blank"
  page.should have_content "Textarea field can't be blank"
  page.should have_content "Radio button fields can't be blank"
  page.should have_content "String field can't be blank"
  page.should have_content "Decimal field can't be blank"
  page.should have_content "Array checkboxes can't be blank"
  page.should have_content "Boolean checkbox can't be blank"
  page.should have_content "Photo Input can't be blank"
  page.should have_content "Attachment Input can't be blank"
  page.should have_content "Area of expertise can't be blank"
  page.should have_content "Languages can't be blank"
  page.should have_content "Phot can't be blank"
  page.should have_content "Att can't be blank"
  page.should have_content "Name can't be blank"
  ['.user_avatar',
   '.user_buyer_profile_properties_textarea_field',
   '.user_buyer_profile_properties_radio_button_fields',
   '.user_buyer_profile_properties_string_field',
   '.user_buyer_profile_properties_decimal_field',
   '.user_buyer_profile_properties_array_checkboxes',
   '.user_buyer_profile_properties_boolean_checkbox',
   '.user_buyer_profile_custom_images__image',
   '.user_buyer_profile_custom_attachments__file',
   '.user_buyer_profile_categories_Area',
   '.user_buyer_profile_categories_Languages',
   '.user_buyer_profile_customizations_Everything_Model_custom_images__image',
   '.user_buyer_profile_customizations_Everything_Model_custom_attachments__file',
   '.user_buyer_profile_customizations_Everything_Model_properties_name'].each do |input_wrapper_klass|
    within(input_wrapper_klass) do
      page.should have_content "can't be blank"
    end
  end

  # this is optional category - no validation here
  within('.user_buyer_profile_categories_Industry') do
    page.should_not have_content "can't be blank"
  end
end

When(/^I upload images and attachments without filling rest of the form$/) do
  attach_file find('.user_buyer_profile_custom_attachments__file input[type="file"]', visible: false)[:name], File.join(Rails.root, 'test', 'assets', 'hello.pdf')
  attach_file find('.user_buyer_profile_custom_images__image input[type="file"]', visible: false)[:name], File.join(Rails.root, 'test', 'assets', 'bully.jpeg')

  attach_file find('.user_buyer_profile_customizations_Everything_Model_custom_images__image input[type="file"]', visible: false)[:name], File.join(Rails.root, 'test', 'assets', 'foobear.jpeg')
  attach_file find('.user_buyer_profile_customizations_Everything_Model_custom_attachments__file input[type="file"]', visible: false)[:name], File.join(Rails.root, 'test', 'assets', 'bully.jpeg')
  click_button 'Save'
end

Then(/^All images and attachments are properly stored and persisted$/) do
  within('.user_buyer_profile_custom_images__image') do
    assert page.find('a.action--preview')[:href].include?('bully.jpeg')
  end
  within('.user_buyer_profile_custom_attachments__file') do
    page.should have_content('840 Bytes')
    assert page.find('a[download]')[:href].include?('hello.pdf')
  end
  within('.user_buyer_profile_customizations_Everything_Model_custom_images__image') do
    assert page.find('a.action--preview')[:href].include?('foobear.jpeg')
  end
  within('.user_buyer_profile_customizations_Everything_Model_custom_attachments__file') do
    assert page.find('a[download]')[:href].include?('bully.jpeg')
    page.should have_content('33.9 KB')
  end
  assert_equal ['bully.jpeg', 'foobear.jpeg'], CustomImage.where(owner_type: nil, owner_id: nil).order('image').pluck(:image)
  assert_equal ['bully.jpeg', 'hello.pdf'], CustomAttachment.where(owner_type: nil, owner_id: nil).order('file').pluck(:file)
end

When(/^I add two and remove one customization and submit form again to see what happens$/) do
  page.find('a[data-association="Everything Model"]').click

  within('.nested-fields-set > .nested-fields') do
    attach_file find('.user_buyer_profile_customizations_Everything_Model_new_Everything_Model_custom_attachments__file input[type="file"]', visible: false)[:name], File.join(Rails.root, 'test', 'assets', 'bully.jpeg')
    attach_file find('.user_buyer_profile_customizations_Everything_Model_new_Everything_Model_custom_images__image input[type="file"]', visible: false)[:name], File.join(Rails.root, 'test', 'assets', 'foobear.jpeg')
    find('a.remove_fields').click
  end

  page.find('a[data-association="Everything Model"]').click
  within('.nested-fields-set > .nested-fields') do
    attach_file find('.user_buyer_profile_customizations_Everything_Model_new_Everything_Model_custom_attachments__file input[type="file"]', visible: false)[:name], File.join(Rails.root, 'test', 'assets', 'foobear.jpeg')
    attach_file find('.user_buyer_profile_customizations_Everything_Model_new_Everything_Model_custom_images__image input[type="file"]', visible: false)[:name], File.join(Rails.root, 'test', 'assets', 'bully.jpeg')
    fill_in find('#user_buyer_profile_attributes_customizations_attributes_Everything_Model_attributes_new_Everything_Model_properties_attributes_name')[:name], with: 'my name'
  end
  click_button 'Save'
end

Then(/^The previously uploaded images and attachments stay untouched and new ones are persisted$/) do
  within('.user_buyer_profile_custom_images__image') do
    assert page.find('a.action--preview')[:href].include?('bully.jpeg')
  end
  within('.user_buyer_profile_custom_attachments__file') do
    page.should have_content('840 Bytes')
    assert page.find('a[download]')[:href].include?('hello.pdf')
  end
  within('.nested-container:first-child .user_buyer_profile_customizations_Everything_Model_custom_images__image') do
    assert page.find('a.action--preview')[:href].include?('foobear.jpeg')
  end
  within('.nested-container:first-child .user_buyer_profile_customizations_Everything_Model_custom_attachments__file') do
    assert page.find('a[download]')[:href].include?('bully.jpeg')
    page.should have_content('33.9 KB')
  end
  within('.nested-container:nth-of-type(2)') do
    within('.user_buyer_profile_customizations_Everything_Model_custom_images__image') do
      assert page.find('a.action--preview')[:href].include?('bully.jpeg')
    end
    within('.user_buyer_profile_customizations_Everything_Model_custom_attachments__file') do
      assert page.find('a[download]')[:href].include?('foobear.jpeg')
      page.should have_content('50.1 KB')
    end
  end
  assert_equal ['bully.jpeg', 'bully.jpeg', 'foobear.jpeg'], CustomImage.where(owner_type: nil, owner_id: nil).order('image').pluck(:image)
  assert_equal ['bully.jpeg', 'foobear.jpeg', 'hello.pdf'], CustomAttachment.where(owner_type: nil, owner_id: nil).order('file').pluck(:file)
end

When(/^I remove first set of images and swap the other$/) do
  within('.nested-container:first-child') do
    find('a.remove_fields').click
  end
  # swap image with attachment to check if update work despite validation error :)
  within('.nested-container:nth-of-type(2)') do
    attach_file find('.user_buyer_profile_customizations_Everything_Model_custom_images__image input[type="file"]', visible: false)[:name], File.join(Rails.root, 'test', 'assets', 'foobear.jpeg')
    # unfortunately image hides the attachment input field, so we need to use some js hack to make it visible
    page.execute_script("$('.nested-container:nth-of-type(2) .user_buyer_profile_customizations_Everything_Model_custom_images__image .file-upload').hide()")
    attach_file find('.user_buyer_profile_customizations_Everything_Model_custom_attachments__file input[type="file"]', visible: false)[:name], File.join(Rails.root, 'test', 'assets', 'bully.jpeg')
    fill_in find('.user_buyer_profile_customizations_Everything_Model_properties_name input')[:name], with: 'my name'
  end
  click_button 'Save'
end

Then(/^The first set is removed and other is swappped$/) do
  within('.user_buyer_profile_custom_images__image') do
    assert page.find('a.action--preview')[:href].include?('bully.jpeg')
  end
  within('.user_buyer_profile_custom_attachments__file') do
    page.should have_content('840 Bytes')
    assert page.find('a[download]')[:href].include?('hello.pdf')
  end
  page.should have_css('.customizations .nested-container', count: 1)
  within('.nested-container') do
    within('.user_buyer_profile_customizations_Everything_Model_custom_images__image') do
      assert page.find('a.action--preview')[:href].include?('foobear.jpeg')
    end
    within('.user_buyer_profile_customizations_Everything_Model_custom_attachments__file') do
      assert page.find('a[download]')[:href].include?('bully.jpeg')
      page.should have_content('33.9 KB')
    end
    assert_equal 'my name', find('.user_buyer_profile_customizations_Everything_Model_properties_name input').value
  end
  assert_equal ['bully.jpeg', 'foobear.jpeg', 'foobear.jpeg'], CustomImage.where(owner_type: nil, owner_id: nil).order('image').pluck(:image)
  assert_equal ['bully.jpeg', 'bully.jpeg', 'hello.pdf'], CustomAttachment.where(owner_type: nil, owner_id: nil).order('file').pluck(:file)
end

When(/^I fill rest of the form$/) do
  fill_in 'user[name]', with: 'New Name'
  attach_file('user[avatar]', File.join(Rails.root, 'features', 'fixtures', 'photos', 'intern chair.jpg'))
  fill_in 'user[current_address_attributes][address]', with: 'Adelaide'
  fill_in 'user[mobile_number]', with: '123456789'
  fill_in 'user[buyer_profile_attributes][properties_attributes][textarea_field]', with: 'text area value'
  within('.user_buyer_profile_properties_radio_button_fields') do
    page.execute_script("document.getElementById('user_buyer_profile_attributes_properties_attributes_radio_button_fields_two').checked = true")
  end
  fill_in 'user[buyer_profile_attributes][properties_attributes][string_field]', with: 'string value'
  fill_in 'user[buyer_profile_attributes][properties_attributes][decimal_field]', with: 35.23
  within('.user_buyer_profile_properties_array_checkboxes') do
    page.execute_script("document.getElementById('user_buyer_profile_attributes_properties_attributes_array_checkboxes_one').checked = true")
    page.execute_script("document.getElementById('user_buyer_profile_attributes_properties_attributes_array_checkboxes_three').checked = true")
  end
  page.execute_script("document.getElementById('user_buyer_profile_attributes_properties_attributes_boolean_checkbox').checked = true")

  choose_selectize '.user_tag_list', 'my tag'
  choose_selectize '.user_tag_list', 'another tag'
  click_link 'Management'
  click_link 'Organization'
  click_link 'M&A and Divestitures'

  click_link 'French'
  click_link 'Polish'

  click_button 'Save'
end

Then(/^all data is properly stored in DB and the form is re\-rendered with those value filled$/) do
  within('.user_buyer_profile_custom_images__image') do
    assert page.find('a.action--preview')[:href].include?('bully.jpeg')
  end
  within('.user_buyer_profile_custom_attachments__file') do
    page.should have_content('840 Bytes')
    assert page.find('a[download]')[:href].include?('hello.pdf')
  end
  page.should have_css('.customizations .nested-container', count: 1)
  within('.nested-container') do
    within('.user_buyer_profile_customizations_Everything_Model_custom_images__image') do
      assert page.find('a.action--preview')[:href].include?('foobear.jpeg')
    end
    within('.user_buyer_profile_customizations_Everything_Model_custom_attachments__file') do
      assert page.find('a[download]')[:href].include?('bully.jpeg')
      page.should have_content('33.9 KB')
    end
    assert_equal 'my name', find('.user_buyer_profile_customizations_Everything_Model_properties_name input').value
  end

  assert_equal 'Adelaide SA, Australia', find('#user_current_address_attributes_address').value
  assert_equal '123456789', find('#user_mobile_number').value
  assert_equal 'text area value', find('#user_buyer_profile_attributes_properties_attributes_textarea_field').value

  assert find('#user_buyer_profile_attributes_properties_attributes_radio_button_fields_two').checked?
  assert_equal 'string value', find('#user_buyer_profile_attributes_properties_attributes_string_field').value
  assert_equal '35.23', find('#user_buyer_profile_attributes_properties_attributes_decimal_field').value

  assert find('#user_buyer_profile_attributes_properties_attributes_array_checkboxes_one').checked?
  refute find('#user_buyer_profile_attributes_properties_attributes_array_checkboxes_two').checked?
  assert find('#user_buyer_profile_attributes_properties_attributes_array_checkboxes_three').checked?

  assert find('#user_buyer_profile_attributes_properties_attributes_boolean_checkbox').checked?

  within('.user_buyer_profile_categories_Area') do
    page.should have_css('.value-inputs input', count: 3, visible: false)
    assert find('a', text: /\AManagement\z/)[:class].include?('jstree-checked')
    assert find('a', text: /\AOrganization\z/)[:class].include?('jstree-checked')
    assert find('a', text: /\AM&A and Divestitures\z/)[:class].include?('jstree-checked')
    refute find('a', text: /\AInnovation\z/)[:class].include?('jstree-checked')
  end

  within('.user_buyer_profile_categories_Languages') do
    page.should have_css('.value-inputs input', count: 2, visible: false)
    assert find('a', text: /\APolish\z/)[:class].include?('jstree-checked')
    assert find('a', text: /\AFrench\z/)[:class].include?('jstree-checked')
    refute find('a', text: /\ASpanish\z/)[:class].include?('jstree-checked')
  end
  assert_equal 'another tag,my tag', find('#user_tag_list', visible: false).value
  page.should have_css('.user_avatar a.action--preview')

  assert_equal ['bully.jpeg', 'foobear.jpeg'], CustomImage.where.not(owner_type: nil, owner_id: nil).order('image').pluck(:image)
  assert_equal ['bully.jpeg', 'hello.pdf'], CustomAttachment.where.not(owner_type: nil, owner_id: nil).order('file').pluck(:file)
end
