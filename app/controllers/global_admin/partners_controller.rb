class GlobalAdmin::PartnersController < GlobalAdmin::ResourceController
  belongs_to :instance, parent_class: Instance
  before_filter :set_instance, except: [:destroy]

  # HACK: because build_resource doesn't work here
  # https://github.com/josevalim/inherited_resources/blob/v1.5.0/lib/inherited_resources/base_helpers.rb#L58
  def create(options = {}, &block)
    object = end_of_association_chain.build
    object.assign_attributes(*resource_params)
    set_resource_ivar(object)

    options[:location] ||= smart_resource_url if create_resource(object)

    respond_with_dual_blocks(object, options, &block)
  end

  def partner_params
    params.require(:partner).permit(secured_params.partner).tap do |p|
      # TODO: HACK
      # accepts_nested_attributes_for :theme, reject_if: proc { |params| params[:name].blank? }
      # reject_if block doesn't work in app/models/partner.rb  :(
      p.delete('theme_attributes') if p['theme_attributes'] && p['theme_attributes']['name'].blank?
    end
  end

  private

  def set_instance
    @instance = Instance.find(params[:instance_id])
  end
end
