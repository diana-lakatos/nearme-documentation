module BuySellMarket::ProductsHelper

  def options_for_dimensions_templates_select(dimensions_templates)
    result_text = "<option disabled selected> -- select an option -- </option>"

    dimensions_templates.each do |dimensions_template|
      result_text += "<option value='#{dimensions_template.id}' data-template='#{dimensions_template.to_json(only: [:name, :unit_of_measure, :weight, :height, :width, :depth, :weight_unit, :height_unit, :width_unit, :depth_unit, :use_as_default])}'>#{dimensions_template.name}</option>"
    end

    raw result_text
  end

  def collection_for_shipping_profiles_radio_buttons(object)
    collection = object.respond_to?(:each) ? object : object.all_shipping_categories
    collection.collect do |sc|
      [
       sc.id,
       raw("#{h(sc.name)} #{link_to("Edit", '#', data: { href: edit_dashboard_shipping_category_path(sc), modal: true, 'modal-class' => 'shipping_profiles_modal' }, class: 'shipping_profiles_modal_edit_link')}")
      ]
    end
  end

  def dashboard_collection_for_shipping_profiles_radio_buttons(object)
    collection = object.respond_to?(:each) ? object : object.all_shipping_categories
    collection.collect do |sc|
      [
       sc.id,
       raw("#{h(sc.name)} #{link_to("Edit", edit_dashboard_shipping_category_path(sc), data: { modal: true, 'modal-class' => 'shipping_profiles_modal' }, class: 'shipping_profiles_modal_edit_link')}")
      ]
    end
  end
end
