# frozen_string_literal: true
module WithParameterizedName
  extend ActiveSupport::Concern
  included do
    scope :with_parameterized_name, ->(name) { find_by(parameterized_name: parameterize_name(name)) }
    before_save :generate_parameterized_name, if: ->(object) { object.name_changed? }
    class << self
      def parameterize_name(name)
        name.to_s.downcase.tr(' ', '_')
      end
    end

    def generate_parameterized_name
      self.parameterized_name = self.class.parameterize_name(name)
    end
  end
end
