class InstanceAdmin::Manage::OfferTypes::CustomValidatorsController < InstanceAdmin::CustomValidatorsController

  protected

  def redirect_path
    instance_admin_manage_offer_type_custom_validators_path(@validatable)
  end

  def find_validatable
    @validatable = OfferType.find(params[:offer_type_id])
  end

  def permitting_controller_class
    @controller_scope ||= 'manage'
  end

  def available_attributes
    @attributes = Transactable.column_names.map{ |column| [column.humanize, column] }
  end

  def set_breadcrumbs
    @breadcrumbs_title = BreadcrumbsList.new(
      { :url => instance_admin_manage_offer_types_path, :title => t('instance_admin.manage.offer_types.offer_types') },
      { :url => instance_admin_manage_offer_type_custom_validators_path, :title => t('instance_admin.manage.offer_types.custom_validators') }
    )
  end
end
