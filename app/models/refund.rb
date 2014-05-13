class Refund < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail
  belongs_to :reference, :polymorphic => true

  scope :successful, -> { where(:success => true) }

  monetize :amount

  attr_encrypted :response, :key => DesksnearMe::Application.config.secret_token, :if => DesksnearMe::Application.config.encrypt_sensitive_db_columns

  def refund_successful(response)
    self.success = true
    self.response = response.to_yaml
    save!
  end

  def refund_failed(response)
    self.success = false
    self.response = response.to_yaml
    save!
  end

end
