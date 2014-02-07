class Charge < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid

  belongs_to :user
  belongs_to :reference, :polymorphic => true

  scope :successful, where(:success => true)

  monetize :amount, :as => :price

  attr_encrypted :response, :key => DesksnearMe::Application.config.secret_token, :if => DesksnearMe::Application.config.encrypt_sensitive_db_columns

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
