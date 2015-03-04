class ApprovalRequestTemplateCreation

  attr_accessor :approval_request_template

  def initialize(approval_request_template)
    @approval_request_template = approval_request_template
  end

  def create
    if @approval_request_template.save
      surface_approval_request_in_space_wizard

      true
    else
      false
    end
  end

  private

  def get_or_create_form_component(transactable_type)
    form_component = FormComponent.where(:form_type => FormComponent::SPACE_WIZARD, :form_componentable => transactable_type).detect do |form_component|
      form_component.name == I18n.t('instance_admin.form_components.approval_requests_section_title')
    end

    if form_component.blank?
      form_component = FormComponent.new
      form_component.name = I18n.t('instance_admin.form_components.approval_requests_section_title')
      form_component.form_type = FormComponent::SPACE_WIZARD
      form_component.form_componentable = transactable_type
      current_max_rank = FormComponent.where(:form_type => FormComponent::SPACE_WIZARD, :form_componentable => transactable_type).maximum(:rank)
      next_max_rank = current_max_rank.nil? ? 0 : current_max_rank + 1
      form_component.rank = next_max_rank
      form_component.save
    end

    form_component
  end

  def is_already_present(transactable_type)
    FormComponent.where(:form_type => FormComponent::SPACE_WIZARD, :form_componentable => transactable_type).detect do |form_component|
      form_component.form_fields.detect do |form_field|
        form_field[@approval_request_template.owner_type.to_s.underscore] == 'approval_requests'
      end.present?
    end.present?
  end

  def surface_approval_request_in_space_wizard
    @approval_request_template.instance.transactable_types.each do |transactable_type|
      if !is_already_present(transactable_type)
        form_component = get_or_create_form_component(transactable_type)

        form_component.form_fields << { @approval_request_template.owner_type.to_s.underscore => 'approval_requests' }

        form_component.save
      end
    end
  end

end

