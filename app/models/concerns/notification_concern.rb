# frozen_string_literal: true
module NotificationConcern
  extend ActiveSupport::Concern

  included do
    scope :enabled, -> { where(enabled: true) }

    has_many :form_configuration_notifications, as: :notification, dependent: :destroy
    has_many :form_configurations, through: :form_configuration_notifications

    validates :name, presence: true
    validates :to, presence: true

    before_save :generate_parameterized_name, if: ->(object) { object.name_changed? }

    class << self
      def parameterize_name(name)
        name.to_s.downcase.tr(' ', '_')
      end
    end

    def generate_parameterized_name
      self.name = self.class.parameterize_name(name)
    end
  end
end
