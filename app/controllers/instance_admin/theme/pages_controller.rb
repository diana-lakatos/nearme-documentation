class InstanceAdmin::Theme::PagesController < InstanceAdmin::Theme::BaseController

  def index
  end

  before_filter :set_redirect_form

  def create
    @page = Page.new(page_params)
    @page.theme_id = PlatformContext.current.theme.id
    create! do |format|
      format.html do
        redirect_to action: 'index'
      end
      format.json do
        render :nothing => true
      end
    end
  end

  def edit
    @redirect_form = resource.try(:redirect?)
    edit!
  end

  def update
    update! do |format|
      format.html do
        redirect_to action: 'index'
      end
      format.json do
        render :nothing => true
      end
    end
  end

  private

  def set_redirect_form
    @redirect_form = params[:redirect].present?
  end

  def page_params
    params.require(:page).permit(secured_params.page)
  end
end
