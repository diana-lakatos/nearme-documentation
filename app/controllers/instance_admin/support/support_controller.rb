class InstanceAdmin::Support::SupportController < InstanceAdmin::BaseController
  
  def index
    @tickets = platform_context.instance.tickets.for_filter(filter).paginate(page: params[:page])
    @filter = filter
    @filter_name = filter_name[@filter]
  end

  def filter
    params[:filter].presence || 'open'
  end

  def filter_name
    {
      "open" => translated_filter_name(:open),
      "resolved" => translated_filter_name(:resolved),
      "all" => translated_filter_name(:all)
    }
  end

  def permitting_controller_class
    'support'
  end

  private

  def translated_filter_name(name)
    I18n.translate(name, scope: ['instance_admin', 'manage', 'support', 'filter_name'])
  end
end
