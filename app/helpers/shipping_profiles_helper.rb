module ShippingProfilesHelper
  def options_for_dimensions_templates_select(dimensions_templates)
    result_text = '<option disabled selected> -- select an option -- </option>'

    dimensions_templates.each do |dimensions_template|
      result_text += "<option value='#{dimensions_template.id}' data-template='#{dimensions_template.to_json(only: [:name, :unit_of_measure, :weight, :height, :width, :depth, :weight_unit, :height_unit, :width_unit, :depth_unit, :use_as_default])}'>#{dimensions_template.name}</option>"
    end

    raw result_text
  end

  def dashboard_collection_for_shipping_profiles_radio_buttons(object)
    collection = object.respond_to?(:each) ? object : ShippingProfile.where('global = true OR user_id IN (?)', current_user.id)
    options = collection.collect do |sc|
      links = ['']
      links << [link_to(t('general.edit'), edit_dashboard_shipping_profile_path(sc), data: { modal: true, 'modal-class' => 'shipping_profiles_modal' }, class: 'shipping_profiles_modal_edit_link')]
      links << link_to(t('general.delete'), dashboard_shipping_profile_path(sc), remote: true, method: :delete, class: 'shipping_profiles_modal_edit_link') if sc.user_id == current_user.id && !sc.global?
      [
        raw("#{h(sc.name)} #{links.join(' | ')}"),
        sc.id,
        { data: { shipping_type: sc.shipping_type } }
      ]
    end
    options << [
      t('transactables.disable_shipping'),
      '0',
      { data: { shipping_type: 'predefined' } }
    ]
  end
end
