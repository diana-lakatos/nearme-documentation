module ProductHelper

  def create_first_shipping_profile
    shipping_category = FactoryGirl.create(:shipping_category)
    user = model!("user")
    shipping_category.user_id = user.id
    shipping_category.save!
  end

  def fill_product_form
    fill_in 'product_form_name', with: 'iPhone'
    fill_in_ckeditor 'product_form_description', with: 'iPhone description'
    fill_in 'product_form_price', with: '100'
    fill_in 'product_form_quantity', with: '100'

    page.execute_script("$('[data-shipping-methods-list] span.radio input').attr('checked', true)")
  end

  def assert_product_data(product)
    stock_location = product.company.stock_locations.first
    stock_item = stock_location.stock_items.where(variant_id: product.master.id).first

    assert !product.shipping_category_id.nil?
    assert_equal 'iPhone', product.name
    assert_equal 'iPhone description', ActionView::Base.full_sanitizer.sanitize(product.description.strip)
    assert_equal 100, product.price
    assert_equal 100, stock_item.stock_movements.sum(:quantity)
  end

  def add_new_shipping_method
    find(".add_shipping_profile").click
    fill_in 'shipping_category_form_name', with: 'DHL'
    fill_in 'shipping_category_form_shipping_methods_attributes_0_name', with: 'DHL'
    fill_in 'shipping_category_form_shipping_methods_attributes_0_processing_time', with: '1'
    fill_in 'shipping_category_form_shipping_methods_attributes_0_calculator_attributes_preferred_amount', with: '1'
    choose_selectize '.country-based', 'United'
    page.execute_script("$('.dialog__actions input[type=submit]').click()")
    wait_for_ajax
    page.execute_script("$('[data-shipping-methods-list] span.radio input').attr('checked', true)")
  end

  def fill_product_fields
    fill_in 'boarding_form_company_attributes_name', with: 'Socks Store'
    fill_in 'boarding_form_company_attributes_company_address_attributes_address', with: 'usa'
    fill_in 'boarding_form_product_form_name', with: 'Nice Sock'
    fill_in_ckeditor 'boarding_form_product_form_description', with: 'Sock description'
    fill_in 'boarding_form_product_form_price', with: '100'
    fill_in 'boarding_form_product_form_quantity', with: '100'
    attach_file_via_uploader
    wait_for_ajax
  end

  def add_new_integrated_shipping_method
    page.execute_script("$('#boarding_form_product_form_shippo_enabled').click()")
    fill_in 'boarding_form_product_form_weight', with: '10'
    fill_in 'boarding_form_product_form_depth', with: '10'
    fill_in 'boarding_form_product_form_width', with: '10'
    fill_in 'boarding_form_product_form_height', with: '10'
  end
end

World(ProductHelper)
