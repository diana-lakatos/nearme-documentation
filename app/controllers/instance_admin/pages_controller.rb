class InstanceAdmin::PagesController < InstanceAdmin::ResourceController

  def create
    @page = Page.new(params[:page])
    @page.theme = platform_context.theme
    create!
  end

end
