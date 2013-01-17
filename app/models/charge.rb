class Charge < ActiveRecord::Base
  belongs_to :user
  belongs_to :reference, :polymorphic => true

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
