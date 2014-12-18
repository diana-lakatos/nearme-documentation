Spree::StockItem.class_eval do
  include Spree::Scoper

  accepts_nested_attributes_for :stock_movements

  _validators.reject!{ |key, _| [:stock_location].include?(key) }

  _validate_callbacks.reject! do |callback|
    callback.raw_filter.attributes.delete :stock_location if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
  end

end
