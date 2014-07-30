Spree::Order.class_eval do
  include Spree::Scoper

  belongs_to :company
  belongs_to :instance
  belongs_to :partner

  scope :completed, -> { where(state: 'complete') }
end
