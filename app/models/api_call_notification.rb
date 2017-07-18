# frozen_string_literal: true
class ApiCallNotification < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  include NotificationConcern

  REQUEST_TYPE = %w(GET POST PUT DELETE).freeze

  validates :request_type, inclusion: { in: REQUEST_TYPE }
  validate :headers_is_parsable

  validates :to, :name, :content, :instance_id, :format, :request_type, presence: true

  protected

  def headers_is_parsable
    JSON.parse(headers)
  rescue JSON::ParserError
    errors.add(:headers, 'not valid json')
  end
end
