module SearchEnginesStructuredDataHelper
  def product_structured_data(product: nil)
    product ||= @product
    render partial: 'shared/structured_data/product', locals: { product: product }
  end

  def transactable_structured_data(transactable: nil)
    transactable ||= @listing
    render partial: 'shared/structured_data/transactable', locals: { transactable: transactable }
  end
end
