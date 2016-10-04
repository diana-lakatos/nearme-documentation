class MarketplaceError < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  before_save :truncate_text_fields

  protected

  # We want to truncate text fields to avoid swelling DB tables as
  # has happened before
  def truncate_text_fields
    self.message = self.message.to_s[0...1000]
    self.stacktrace = self.stacktrace.to_s[0...1000]

    true
  end

end
