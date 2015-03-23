module BuySellMarket::ProductsHelper

  def options_for_dimensions_templates_select(dimensions_templates)
    result_text = "<option disabled selected> -- select an option -- </option>"

    dimensions_templates.each do |dimensions_template|
      result_text += "<option value='#{dimensions_template.id}' data-template='#{dimensions_template.to_json(only: [:name, :unit_of_measure, :weight, :height, :width, :depth, :weight_unit, :height_unit, :width_unit, :depth_unit])}'>#{dimensions_template.name}</option>"
    end

    raw result_text
  end

  def collection_for_shipping_profiles_radio_buttons(product_form)
    product_form.all_shipping_categories.collect do |sc|
      [
       sc.id,
       raw("#{h(sc.name)} #{link_to("Edit", '#', data: { href: edit_dashboard_shipping_category_path(sc), modal: true, 'modal-class' => 'shipping_profiles_modal' }, class: 'shipping_profiles_modal_edit_link')}")
      ]
    end
  end

  def image_for_table(product)
    if photo = product.images.first
      link_to product_path(product) do
        image_tag photo.image.current_url(:thumb), :title => product.name, :alt => product.name
      end
    end
  end

end
