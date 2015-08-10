class ProductTypeSelectTag < TransactableTypeSelectTag
  def klass
    Spree::ProductType
  end

  def classes
    %w(product-type-select-tag) + super
  end
end

Liquid::Template.register_tag('product_type_select', ProductTypeSelectTag)
