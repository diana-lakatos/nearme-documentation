class Payout < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail
  belongs_to :reference, :polymorphic => true

  scope :successful, where(:success => true)

  monetize :amount

  def payout_successful(response)
    self.success = true
    self.response = response.to_yaml
    save!
  end

  def payout_failed(response)
    self.success = false
    self.response = response.to_yaml
    save!
  end

end
