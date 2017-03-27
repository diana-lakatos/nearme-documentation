# frozen_string_literal: true
class TransactablesForm < BaseForm
  POPULATOR = lambda do |collection:, fragment:, as:, index:, **_args|
    name_to_transactable_type_hash ||= {}
    transactable_type = name_to_transactable_type_hash[as] ||= TransactableType.with_parameterized_name(as)
    raise ArgumentError, "Transactable Type #{as} does not exist. Did you mean one of: #{TransactableType.pluck(:parameterized_name).join(',')} ?" if transactable_type.nil?
    raise ArgumentError, "Transactable Type #{as} is not associated with the object to which you try to add it." if send(transactable_type.parameterized_name).nil?
    item = send(transactable_type.parameterized_name).find { |c| c.id.to_s == fragment['id'].to_s && fragment['id'].present? }
    if fragment['_destroy'] == '1'
      send(transactable_type.parameterized_name).delete(item)
      return skip!
    end
    item ? item : send(transactable_type.parameterized_name).append(transactable_type.transactables.build)
  end.freeze

  class << self
    def decorate(configuration)
      Class.new(self) do
        configuration.each do |transactable_type_name, fields|
          @@mapping_hash ||= {}
          @@mapping_hash[transactable_type_name] = fields.dup
          validation = fields.delete(:validation)
          validates :"#{transactable_type_name}", validation if validation.present?
          collection :"#{transactable_type_name}",
                     form: TransactableForm.decorate(fields),
                     populator: POPULATOR,
                     prepopulator: ->(*) { send(:"#{transactable_type_name}").send(:<<, TransactableType.with_parameterized_name(transactable_type_name).transactables.build) if send(transactable_type_name).size.zero? }

          # used by cocoon gem to create nested forms
          define_method("build_#{transactable_type_name}") do
            tt = TransactableType.with_parameterized_name(transactable_type_name)
            raise "Couldn't find TransactableType with name: #{transactable_type_name}. Valid names are: #{TransactableType.pluck(:parameterized_name)}" if tt.nil?
            TransactableForm.decorate(@@mapping_hash[transactable_type_name]).new(tt.transactables.build).tap(&:prepopulate!)
          end
        end
      end
    end
  end
end
