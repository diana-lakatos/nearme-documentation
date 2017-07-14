# frozen_string_literal: true
class SubmitForm
  class CallMethodOnModel
    def initialize(method)
      @method = method
    end

    def notify(form:, **)
      form.model.public_send(@method)
    end
  end
end
