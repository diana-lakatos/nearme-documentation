# frozen_string_literal: true
module LinkToAssociation
  class HelpfulLinkToAssociationError < ArgumentError
    class << self
      def raise_form_object_is_nil(tag_name, form_name)
        raise "#{tag_name} - #{form_name}'s object is nil. Maybe form_configuration does not include #{form_name} or fields_for is missing proper form argument?"
      end

      def raise_wrong_variable_name(tag_name, form_name)
        raise "#{tag_name} - #{form_name}'s is not a form. Maybe you used singular name instead of plural or something like this?"
      end

      def raise_form_is_nil(tag_name, form_name)
        raise "#{tag_name} - #{form_name} is nil. Maybe fields_for is missing proper 'form' argument or you have a typo?"
      end
    end
  end
end
