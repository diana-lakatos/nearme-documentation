# frozen_string_literal: true
class SimpleForm::FormBuilderDrop < BaseDrop
  # @!method object_name
  #   @return [String] name of the encapsulated object
  # @!method object
  #   @return [Object] encapsulated object
  delegate :object_name, :object, to: :source
end
