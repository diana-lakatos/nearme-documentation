# frozen_string_literal: true
class Admin::Design::PagesController < Admin::Design::BaseController
  include Admin::Versionable

  before_action :set_redirect_form
  before_action :find_page, only: [:edit, :update, :destroy]

  def index
    @pages = platform_context.theme.pages
  end

  def new
  end

  def create
    @page = Page.new(page_params)
    @page.theme_id = PlatformContext.current.theme.id
    if @page.save!
      flash[:success] = 'Page was created successfully'
      redirect_to edit_admin_design_page_path(@page)
    else
      flash.now[:error] = @page.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    @redirect_form = @page.try(:redirect?)
  end

  def update
    if @page.update_attributes(page_params)
      flash[:success] = 'Page details were saved'
      redirect_to edit_admin_design_page_path(@page)
    else
      flash.now[:error] = @page.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @page.destroy
    flash[:success] = t 'admin.pages.flash.destroyed'
    redirect_to action: :index
  end

  def delete_image
    @page.remove_hero_image!
    @page.save!

    redirect_to edit_admin_design_page_path(@page)
  end

  private

  def set_redirect_form
    @redirect_form = params[:redirect].present?
  end

  def page_params
    params.require(:page).permit(secured_params.page)
  end

  def find_page
    @page = Page.find(params[:id])
  end
end
