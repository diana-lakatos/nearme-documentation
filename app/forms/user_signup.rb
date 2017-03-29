# frozen_string_literal: true
class UserSignup < UserForm
  validates :email, presence: true
  validates :password, presence: true
end
