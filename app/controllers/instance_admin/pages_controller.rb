class InstanceAdmin::PagesController < InstanceAdmin::ResourceController

  def create
    @page = Page.new(params[:page])
    @page.theme = platform_context.theme
    create!
  end

  def update
    update! do |format|
      format.html
      format.json do
        render :nothing => true
      end
    end
  end

end
