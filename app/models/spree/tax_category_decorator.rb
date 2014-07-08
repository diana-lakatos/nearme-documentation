Spree::TaxCategory.class_eval do
  scoped_to_platform_context

  _validators.reject!{ |key, _| key == :name }

  _validate_callbacks.reject! do |callback|
    callback.raw_filter.attributes.delete :name if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
  end

  validates :name, presence: true, uniqueness: {scope: [:deleted_at, :instance_id, :company_id, :partner_id, :user_id]}
end
