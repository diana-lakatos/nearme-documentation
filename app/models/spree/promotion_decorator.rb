Spree::Promotion.class_eval do
  scoped_to_platform_context

  _validators.reject!{ |key, _| key == :path }

  _validate_callbacks.reject! do |callback|
    callback.raw_filter.attributes.delete :path if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
  end

  validates :path, uniqueness: {scope: [:instance_id, :company_id, :partner_id, :user_id]}, allow_blank: true
end
