class Charge < ActiveRecord::Base
  belongs_to :user
  belongs_to :reference, :polymorphic => true

  scope :successful, where(:success => true)
  scope :last_x_days, lambda { |days_in_past| 
    where('charges.created_at >= ? ', Date.today - days_in_past.days)
  }

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
