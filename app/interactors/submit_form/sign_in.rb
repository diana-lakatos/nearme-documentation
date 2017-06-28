# frozen_string_literal: true
class SubmitForm
  class SignIn
    def initialize(controller)
      @controller = controller
    end

    def notify(form:, **)
      @controller.send(:sign_in, form.model)
    end
  end
end
