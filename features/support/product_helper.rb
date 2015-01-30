module ProductHelper

  def fill_product_form
    fill_in 'product_form_name', with: 'iPhone'
    fill_in_ckeditor 'product_form_description', with: 'iPhone description'
    fill_in 'product_form_price', with: '100'
    fill_in 'product_form_quantity', with: '100'
    fill_in 'product_form_shipping_methods_attributes_0_name', with: 'DHL'
    fill_in 'product_form_shipping_methods_attributes_0_processing_time', with: '2'
    fill_in 'product_form_shipping_methods_attributes_0_calculator_attributes_preferred_amount', with: '20'

    find('#s2id_product_form_shipping_methods_attributes_0_zones_attributes_0_state_ids ul.select2-choices').click
    page.should have_css('ul.select2-results li div.select2-result-label')
    first('ul.select2-results li div.select2-result-label').click

    # TODO possible test enhancement: change zone kind to country type
    # within '.product_form_shipping_methods_zones_kind' do
    #   find("button").click
    #   find("li[rel='1']").click
    # end
  end

  def assert_product_data(product)
    stock_location = product.company.stock_locations.first
    stock_item = stock_location.stock_items.where(variant_id: product.master.id).first
    shipping_method = product.shipping_category.shipping_methods.first
    state = Spree::State.order(:name).first

    assert_equal 'iPhone', product.name
    assert_equal 'iPhone description', ActionView::Base.full_sanitizer.sanitize(product.description).strip
    assert_equal 100, product.price
    assert_equal 100, stock_item.stock_movements.sum(:quantity)
    assert_equal "DHL", shipping_method.name
    assert_equal 2, shipping_method.processing_time
    assert_equal 20, shipping_method.calculator.preferred_amount
    assert_equal state, shipping_method.zones.first.members.first.zoneable
  end
end

World(ProductHelper)
