Spree::Order.class_eval do
  scoped_to_platform_context

  belongs_to :company
  belongs_to :instance
  belongs_to :partner

  scope :completed, -> { where(state: 'complete') }
end
