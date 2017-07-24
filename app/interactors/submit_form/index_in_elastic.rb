# frozen_string_literal: true
class SubmitForm
  class IndexInElastic
    def notify(form:, **)
      return unless Rails.application.config.use_elastic_search
      choose_models_to_refresh(form.model).each do |model|
        Elastic::Commands::InstantIndexRecord.new(model).call
      end
    end

    private

    def choose_models_to_refresh(changed_model)
      ElasticObjectDependencyTree.new(changed_model).affected_objects
    end

    class ElasticObjectDependencyTree
      attr_reader :record

      def self.find(record)
        new(record).root
      end

      def initialize(record)
        @record = record
      end

      def affected_objects
        case record
        when User, Transactable, Location then [record]
        when Customization then
          case record.customizable
          when UserProfile then [record.customizable.user]
          when Transactable then [record.customizable]
          end
        when Order then [record.transactable]
        when RecurringBookingPeriod then [record.order.transactable]
        when CustomImage then
          case record.owner
          when UserProfile then record.owner.user
          when Customization then record.owner.customizable.user
          end
        end
      end
    end
  end
end
