# frozen_string_literal: true
class SubmitForm
  class DestroyModel
    def notify(form:, **)
      form.model.destroy
    end
  end
end
