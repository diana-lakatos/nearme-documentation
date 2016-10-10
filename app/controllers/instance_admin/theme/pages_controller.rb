class InstanceAdmin::Theme::PagesController < InstanceAdmin::Theme::BaseController
  include InstanceAdmin::Versionable
  actions :all, except: [:show]

  before_filter :set_redirect_form

  def index
  end

  def create
    @page = Page.new(page_params)
    @page.theme_id = PlatformContext.current.theme.id
    create! do |format|
      format.html do
        redirect_to action: 'index'
      end
      format.json do
        render nothing: true
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
        render nothing: true
      end
    end
  end

  def destroy
    destroy!
    # Inherited resources recommends that we use errors to check whether record was destroyed
    if resource.errors.empty?
      new_page_slug = "#{resource.slug}_#{SecureRandom.hex(30)}"
      new_page_slug = SecureRandom(30) if new_page_slug.length > 255
      resource.update_attribute(:slug, new_page_slug)
    end
  end

  def delete_image
    resource.remove_hero_image!
    resource.save!

    redirect_to edit_instance_admin_theme_page_path
  end

  private

  def set_redirect_form
    @redirect_form = params[:redirect].present?
  end

  def page_params
    params.require(:page).permit(secured_params.page)
  end

  def begin_of_association_chain
    @theme
  end
end
