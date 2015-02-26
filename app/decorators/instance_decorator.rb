class InstanceDecorator < Draper::Decorator
  delegate_all

  def collection_for_form_components_by_type(form_type)
    FormComponent.where(:instance_id => self.id, :form_type => form_type).collect { |form_component| form_component.form_componentable }.uniq.compact.collect { |fc| [fc.name, fc.id] }
  end

end
