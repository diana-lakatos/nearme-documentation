module ProductHelper

  def create_first_shipping_profile
    shipping_category = FactoryGirl.create(:shipping_category)
    user = model!("the user")
    shipping_category.user_id = user.id
    shipping_category.save!
  end

  def fill_product_form
    fill_in 'product_form_name', with: 'iPhone'
    fill_in_ckeditor 'product_form_description', with: 'iPhone description'
    fill_in 'product_form_price', with: '100'
    fill_in 'product_form_quantity', with: '100'

    find('.shipping_method_block.shipping_method_list input').click

    # TODO possible test enhancement: change zone kind to country type
    # within '.product_form_shipping_methods_zones_kind' do
    #   find("button").click
    #   find("li[rel='1']").click
    # end
  end

  def assert_product_data(product)
    stock_location = product.company.stock_locations.first
    stock_item = stock_location.stock_items.where(variant_id: product.master.id).first

    assert !product.shipping_category_id.nil?
    assert_equal 'iPhone', product.name
    assert_equal 'iPhone description', ActionView::Base.full_sanitizer.sanitize(product.description).strip
    assert_equal 100, product.price
    assert_equal 100, stock_item.stock_movements.sum(:quantity)
  end
end

World(ProductHelper)
