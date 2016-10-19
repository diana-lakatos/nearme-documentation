module CarrierWave
  module Cleanable
    extend ActiveSupport::Concern

    included do
      after :remove, :clean_model

      def clean_model
        model.update_attribute(:"#{mounted_as}_transformation_data", nil)
      end
    end
  end
end
