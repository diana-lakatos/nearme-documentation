class HostFeeLineItem < ActiveRecord::Base

  include Modelable

  self.inheritance_column = :type

  monetize :unit_price_cents, with_model_currency: :currency
  monetize :total_price_cents, with_model_currency: :currency

  belongs_to :user, -> { with_deleted }
  belongs_to :company, -> { with_deleted }
  belongs_to :line_itemable, polymorphic: true
  belongs_to :line_item_source, polymorphic: true

  delegate :currency, to: :line_itemable, allow_nil: true

  def total_price_cents
    self.unit_price_cents
  end
end
