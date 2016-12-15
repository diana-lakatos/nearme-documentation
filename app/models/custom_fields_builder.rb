# frozen_string_literal: true
class CustomFieldsBuilder
  def initialize(form_component)
    @form_type = form_component.form_type
    @form_component = form_component
    @form_componentable = form_component.form_componentable
  end

  def all_valid_object_field_pairs
    case @form_type
    when FormComponent::SPACE_WIZARD
      if @form_componentable.instance_of?(ProjectType)
        to_object_field_notation(user_fields, 'user') +
          to_object_field_notation(project_fields, 'project')
      elsif @form_componentable.instance_of?(TransactableType)
        to_object_field_notation(user_fields, 'user') +
          to_object_field_notation(seller_fields, 'seller') +
          to_object_field_notation(company_fields, 'company') +
          to_object_field_notation(location_fields, 'location') +
          to_object_field_notation(transactable_fields, 'transactable')
      else
        raise NotImplementedError, "Unknown form type: #{@form_type}"
      end
    when FormComponent::TRANSACTABLE_ATTRIBUTES
      to_object_field_notation(dashboard_transactable_fields, 'transactable')
    when FormComponent::RESERVATION_ATTRIBUTES
      to_object_field_notation(reservation_fields, 'reservation') +
        to_object_field_notation(user_fields, 'user') +
        to_object_field_notation(buyer_fields, 'buyer') +
        to_object_field_notation(seller_fields, 'seller')
    when FormComponent::INSTANCE_PROFILE_TYPES
      to_object_field_notation(user_fields, 'user') + to_object_field_notation(buyer_fields, 'buyer') +
        to_object_field_notation(seller_fields, 'seller')
    when FormComponent::SELLER_PROFILE_TYPES
      to_object_field_notation(user_fields, 'user') +
        to_object_field_notation(seller_fields, 'seller')
    when FormComponent::BUYER_PROFILE_TYPES
      to_object_field_notation(user_fields, 'user') +
        to_object_field_notation(buyer_fields, 'buyer')
    when FormComponent::SELLER_REGISTRATION
      to_object_field_notation(user_fields, 'user') +
        to_object_field_notation(seller_fields, 'seller')
    when FormComponent::BUYER_REGISTRATION
      to_object_field_notation(user_fields, 'user') +
        to_object_field_notation(seller_fields, 'buyer')
    when FormComponent::DEFAULT_REGISTRATION
      to_object_field_notation(user_fields, 'user')
    when FormComponent::LOCATION_ATTRIBUTES
      to_object_field_notation(location_fields, 'location')
    else
      raise NotImplementedError
    end
  end

  def object_field_pairs
    @object_field_pairs ||= build_object_field_pairs
  end

  def get_label(object_field_pair)
    object = object_field_pair.keys.first
    field = object_field_pair[object]
    "#{object.to_s.humanize} - #{field.to_s.humanize}"
  end

  def valid_object_field_pair?(object_field_pair)
    object = object_field_pair.keys.first
    field = object_field_pair[object]
    all_valid_fields_for_object(object).include?(field)
  end

  protected

  def build_object_field_pairs
    @form_component.form_fields.try(:any?) ? @form_component.form_fields : all_valid_object_field_pairs
  end

  def all_valid_fields_for_object(object)
    case @form_type
    when FormComponent::SPACE_WIZARD
      case object
      when 'user'
        user_fields
      when 'seller'
        seller_fields
      when 'company'
        company_fields
      when 'location'
        location_fields
      when 'transactable'
        transactable_fields
      else
        raise NotImplementedError, "Unknown object for which field #{field} was defined: #{object}. Valid objects: location, address, transactable, product"
      end
    end
  end

  def form_attributes
    @form_attributes = FormAttributes.new
  end

  def user_fields
    @user_fields = form_attributes.user.map(&:to_s)
  end

  def seller_fields
    @seller_fields = form_attributes.seller.map(&:to_s)
  end

  def buyer_fields
    @buyer_fields = form_attributes.buyer.map(&:to_s)
  end

  def company_fields
    @company_fields = form_attributes.company.map(&:to_s)
  end

  def location_fields
    @location_fields = form_attributes.location.map(&:to_s)
  end

  def transactable_fields
    @transactable_fields ||= form_attributes.transactable(@form_componentable).map(&:to_s)
  end

  def dashboard_transactable_fields
    @transactable_fields ||= form_attributes.dashboard_transactable(@form_componentable).map(&:to_s)
  end

  def project_fields
    @project_fields ||= form_attributes.project(@form_componentable).map(&:to_s)
  end

  def reservation_fields
    @reservation_fields ||= form_attributes.reservation(@form_componentable).map(&:to_s)
  end

  def to_object_field_notation(array, object)
    array.map { |field, _label| { object.to_s => field } }
  end
end
