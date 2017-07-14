# frozen_string_literal: true
class SubmitForm
  class IndexInElastic
    def notify(form:, **)
        return unless Rails.application.config.use_elastic_search
        Elastic::Commands::InstantIndexRecord.new(form.model).call
    end
  end
end
