class Charge < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  belongs_to :reference, :polymorphic => true

  scope :successful, where(:success => true)

  monetize :amount, :as => :price
  serialize :response, Hash

  attr_encrypted :response, :key => DesksnearMe::Application.config.secret_token, marshal: true

  def charge_successful(response)
    self.success = true
    self.response = response
    save!
  end

  def charge_failed(response)
    self.success = false
    self.response = response
    save!
  end

end
