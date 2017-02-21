require 'test_helper'

class ApprovalRequestTemplateCreationTest < ActiveSupport::TestCase
  setup do
    @approval_request_templates = []

    ApprovalRequestTemplate::OWNER_TYPES.each do |owner_type|
      approval_request_template = ApprovalRequestTemplate.new
      approval_request_template.owner_type = owner_type

      @approval_request_templates << approval_request_template
    end

    TransactableType.destroy_all
    @transactable_types = []
    1.upto(3) do
      @transactable_types << FactoryGirl.create(:transactable_type)
    end
  end

  should 'surface approval fields for all types' do
    @approval_request_templates.each do |approval_request_template|
      approval_request_template_creation = ApprovalRequestTemplateCreation.new(approval_request_template)
      assert approval_request_template_creation.create
    end

    params = { form_type: FormComponent::SPACE_WIZARD, name: I18n.t('instance_admin.form_components.approval_requests_section_title') }

    0.upto(2) do |index|
      form_components = @transactable_types[index].form_components.where(params)
      assert_equal 1, form_components.length
      assert form_components[0].is_approval_request_surfacing
      all_form_fields = form_components.first.form_fields
      assert_equal 4, all_form_fields.length
      assert_equal 4, ApprovalRequestTemplate::OWNER_TYPES.collect { |owner_type| all_form_fields.detect { |form_field| form_field[owner_type.to_s.underscore] == 'approval_requests' } }.compact.length
    end
  end
end
