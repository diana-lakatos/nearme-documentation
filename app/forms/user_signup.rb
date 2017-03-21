# frozen_string_literal: true
class UserSignup < UserForm
  validates :password, presence: true
end
