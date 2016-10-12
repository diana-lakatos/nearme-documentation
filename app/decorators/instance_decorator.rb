class InstanceDecorator < Draper::Decorator
  delegate_all

  def collection_for_form_components_by_type(form_type, form_componentable)
    form_componentable.class
      .joins(:form_components)
      .where(form_components: { form_type: form_type })
      .distinct
      .order(:name).map { |fc| [fc.name, fc.id] }
  end
end
