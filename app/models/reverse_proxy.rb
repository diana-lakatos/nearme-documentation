class ReverseProxy < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  include DomainsCacheable

  belongs_to :instance
  belongs_to :domain

  before_create :set_environment

  validate :headers_is_parsable

  protected

  def set_environment
    self.environment = Rails.env
  end

  def headers_is_parsable
    JSON.parse(headers)
  rescue JSON::ParserError
    errors.add(:headers, 'not valid json')
  end

end
