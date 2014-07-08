class Admin::PartnersController < Admin::ResourceController
  belongs_to :instance, parent_class: Instance

  # hack because build_resource doesn't work here
  # https://github.com/josevalim/inherited_resources/blob/v1.5.0/lib/inherited_resources/base_helpers.rb#L58
  def create(options={}, &block)
    object = end_of_association_chain.build
    object.assign_attributes(*resource_params)
    set_resource_ivar(object)

    if create_resource(object)
      options[:location] ||= smart_resource_url
    end

    respond_with_dual_blocks(object, options, &block)
  end

  def partner_params
    params.require(:partner).permit(secured_params.partner).tap do |p|
      # TODO HACK
      # accepts_nested_attributes_for :theme, reject_if: proc { |params| params[:name].blank? }
      # reject_if block doesn't work in app/models/partner.rb  :(
      p.delete("theme_attributes") if p["theme_attributes"] and p["theme_attributes"]["name"].blank?
    end
  end
end
