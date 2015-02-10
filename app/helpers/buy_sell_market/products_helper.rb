module BuySellMarket::ProductsHelper

  def options_for_dimensions_templates_select(dimensions_templates)
    result_text = "<option disabled selected> -- select an option -- </option>"

    dimensions_templates.each do |dimensions_template|
      result_text += "<option value='#{dimensions_template.id}' data-template='#{dimensions_template.to_json(only: [:name, :unit_of_measure, :weight, :height, :width, :depth, :weight_unit, :height_unit, :width_unit, :depth_unit])}'>#{dimensions_template.name}</option>"
    end

    raw result_text
  end

end
