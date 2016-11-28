# frozen_string_literal: true
class UserSignup < UserForm
  property :accept_terms_of_service, virtual: true
  validates :password, presence: true
  validates :accept_terms_of_service,
            acceptance: { allow_nil: false,
                          if: -> { PlatformContext.current.instance.force_accepting_tos? } }
end
