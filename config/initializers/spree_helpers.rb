Spree::Admin::BaseHelper.module_eval do
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def available_countries
    checkout_zone = Zone.find_by(name: Spree::Config[:checkout_zone])

    if checkout_zone && checkout_zone.kind == 'country'
      countries = checkout_zone.country_list
    else
      countries = Country.all
    end

    countries.collect do |country|
      country.name = Spree.t(country.iso, scope: 'country_names', default: country.name)
      country
    end.sort { |a, b| a.name.parameterize <=> b.name.parameterize }
  end
end
