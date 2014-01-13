class PlatformInquiry < ActiveRecord::Base
  EMAIL_VALIDATOR = %r{^(?:[_a-z0-9\-\+]+)(\.[_a-z0-9\-\+]+)*@([a-z0-9\-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$}i
  
  validates :email, :name, presence: true
  validates_format_of :email, with: EMAIL_VALIDATOR, multiline: true
end
