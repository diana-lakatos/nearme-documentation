class ApiKey < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance

  before_create :generate_token

  scope :active, -> { where('expires_at IS NULL OR expires_at > ?', Time.now) }

  private

  def generate_token
    begin
      self.token = SecureRandom.hex
    end while self.class.exists?(token: token)
  end
end
