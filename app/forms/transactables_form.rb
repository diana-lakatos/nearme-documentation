# frozen_string_literal: true
class TransactablesForm < BaseForm
  POPULATOR = lambda do |collection:, index:, **args|
    name_to_transactable_type_hash ||= {}
    transactable_type = name_to_transactable_type_hash[args[:as]] ||= TransactableType.find_by(name: args[:as])
    if (transactable = collection[index]).present?
      transactable.transactable_type = transactable_type
    else
      transactable = transactable_type.transactables.build
      collection.insert(index, transactable)
    end
  end.freeze

  class << self
    def decorate(configuration)
      Class.new(self) do
        configuration.each do |transactable_type_name, fields|
          validation = fields.delete(:validation)
          validates :"#{transactable_type_name}", validation if validation.present?
          collection :"#{transactable_type_name}",
                     form: TransactableForm.decorate(fields),
                     populator: POPULATOR,
                     prepopulator: ->(*) { send(:"#{transactable_type_name}").send(:<<, TransactableType.find_by(name: transactable_type_name).transactables.build) if send(transactable_type_name).size.zero? }
        end
      end
    end
  end
end
