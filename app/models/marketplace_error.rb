class MarketplaceError < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  before_save :truncate_text_fields
  before_save :set_message_digest
  before_create :add_to_group
  after_create :update_last_occurence

  belongs_to :marketplace_error_group, inverse_of: :marketplace_errors, counter_cache: true

  protected

  # We want to truncate text fields to avoid swelling DB tables as
  # has happened before
  def truncate_text_fields
    self.message = message.to_s[0...1000]
    self.stacktrace = stacktrace.to_s[0...1000]

    true
  end

  def add_to_group
    group = MarketplaceErrorGroup.where(error_type: error_type,
                                        message_digest: message_digest).first_or_create! do |meg|
      meg.message = message
    end

    self.marketplace_error_group = group

    true
  end

  def update_last_occurence
    marketplace_error_group.last_occurence = created_at
    marketplace_error_group.save!

    true
  end

  def set_message_digest
    self.message_digest = Digest::SHA256.hexdigest(message.to_s)

    true
  end
end
