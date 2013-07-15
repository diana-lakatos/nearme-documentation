class Charge < ActiveRecord::Base
  belongs_to :user
  belongs_to :reference, :polymorphic => true

  scope :successful, where(:success => true)
  scope :last_x_days, lambda { |days_in_past| 
    where('DATE(charges.created_at) >= ? ', Time.zone.today - days_in_past.days)
  }

  #TODO: evaluate if we want to use this instead of dashboard_helper#group_charges
  #scope :grouped_by_date_and_currency, successful.group('DATE(charges.created_at), charges.currency').select('SUM(charges.amount), DATE(charges.created_at), charges.currency')
  scope :all_time_totals, successful.group('charges.currency').select('SUM(charges.amount), charges.currency')


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
