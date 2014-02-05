class InstanceAdmin::PagesController < InstanceAdmin::ResourceController

  before_filter :set_redirect_form

  def create
    @page = Page.new(params[:page])
    @page.theme = platform_context.theme
    create!
  end

  def edit
    @redirect_form = resource.try(:redirect?)
    edit!
  end

  def update
    update! do |format|
      format.html
      format.json do
        render :nothing => true
      end
    end
  end

  private

  def set_redirect_form
    @redirect_form = params[:redirect].present?
  end

end
