class InstanceClient < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  # attr_accessible :client_id, :client_type, :client, :stripe_id, :paypal_id, :balanced_user_id, :balanced_credit_card_id, :bank_account_last_four_digits

  attr_encrypted :stripe_id, :paypal_id, :balanced_user_id, :balanced_credit_card_id, :key => DesksnearMe::Application.config.secret_token, :if => DesksnearMe::Application.config.encrypt_sensitive_db_columns

  belongs_to :client, :polymorphic => true
  belongs_to :instance

  validates_presence_of :client_id, :client_type, :unless => lambda { |ic| ic.client.present? }
end
