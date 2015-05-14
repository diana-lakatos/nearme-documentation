class InstanceDecorator < Draper::Decorator
  delegate_all

  def collection_for_form_components_by_type(form_type, form_componentable_type)
    FormComponent.where(:instance_id => self.id, :form_type => form_type, form_componentable_type: form_componentable_type).collect do |form_component|
      form_component.form_componentable
    end.uniq.compact.collect { |fc| [fc.name, fc.id] }
  end

end
