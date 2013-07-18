class Charge < ActiveRecord::Base
  belongs_to :user
  belongs_to :reference, :polymorphic => true

  scope :successful, where(:success => true)

  monetize :amount, :as => :price

  def charge_successful(gateway_object)
    self.success = true
    self.response = gateway_object.to_yaml
    save!
  end

  def charge_failed(exception)
    self.success = false
    self.response = exception.to_yaml
    save!
  end

end
