class Refund < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :reference, :polymorphic => true
  scope :successful, where(:success => true)

  monetize :amount
  serialize :response, Hash

  attr_encrypted :response, :key => DesksnearMe::Application.config.secret_token, marshal: true

  def refund_successful(response)
    self.success = true
    self.response = response
    save!
  end

  def refund_failed(response)
    self.success = false
    self.response = response
    save!
  end

end
