# frozen_string_literal: true
class SubmitForm
  class LegacyMarkAsOnboarded
    def notify(form:, **)
      form.try(:profiles)&.model&.to_h&.keys&.try(:each) do |profile_name|
        profile = form.profiles.send(:try, profile_name)
        profile.model.mark_as_onboarded! if profile.try(:mark_as_onboarded)
      end
    end
  end
end
