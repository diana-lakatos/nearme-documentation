# frozen_string_literal: true
class SubmitForm
  class ChangeLocale
    def notify(current_user:, **)
      I18n.locale = current_user.reload.language&.to_sym || :en
    end
  end
end
