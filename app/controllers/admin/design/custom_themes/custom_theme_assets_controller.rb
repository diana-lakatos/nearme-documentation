# frozen_string_literal: true
class Admin::Design::CustomThemes::CustomThemeAssetsController < Admin::Design::CustomThemesController
  include Admin::Versionable

  before_action :find_custom_theme_asset, only: [:edit, :update, :destroy]
  set_resource_method :find_custom_theme_asset

  def index
    @custom_theme_assets = custom_theme.custom_theme_assets
  end

  def new
    @custom_theme_asset = custom_theme.custom_theme_assets.build
  end

  def edit
  end

  def create
    @custom_theme_asset = custom_theme.custom_theme_assets.build(custom_theme_asset_params)
    if @custom_theme_asset.save
      if !@custom_theme_asset.file.present? && @custom_theme_asset.body.present? && @custom_theme_asset.supports_body?
        tmp_file = Tempfile.new('tmp_file')
        tmp_file.binmode
        tmp_file << @custom_theme_asset.body
        tmp_file.rewind
        file_params = {
          filename: @custom_theme_asset.name,
          tempfile: tmp_file
        }
        @custom_theme_asset.file = ActionDispatch::Http::UploadedFile.new(file_params)
        @custom_theme_asset.save!
      end
      flash[:success] = t 'flash_messages.instance_admin.manage.custom_theme_assets.created'
      redirect_to action: :index
    else
      flash.now[:error] = @custom_theme_asset.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def update
    @custom_theme_asset.assign_attributes(custom_theme_asset_params)
    @body_changed = @custom_theme_asset.body_changed?
    if @custom_theme_asset.save
      if @body_changed && @custom_theme_asset.body.present? && @custom_theme_asset.supports_body?
        tmp_file = Tempfile.new('tmp_file')
        tmp_file.binmode
        tmp_file << @custom_theme_asset.body
        tmp_file.rewind
        file_params = {
          filename: @custom_theme_asset.name,
          tempfile: tmp_file
        }
        @custom_theme_asset.file = ActionDispatch::Http::UploadedFile.new(file_params)
        @custom_theme_asset.save!
      end
      flash[:success] = t 'flash_messages.instance_admin.manage.custom_theme_assets.updated'
      redirect_to action: :index
    else
      flash.now[:error] = @custom_theme_asset.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @custom_theme_asset.destroy
    flash[:success] = t('flash_messages.instance_admin.manage.custom_theme_assets.deleted')
    redirect_to action: :index
  end

  private

  def custom_theme
    @custom_theme ||= CustomTheme.find(params[:custom_theme_id])
  end

  def custom_theme_asset_params
    params.require(:custom_theme_asset).permit(secured_params.custom_theme_asset)
  end

  def find_custom_theme_asset
    @custom_theme_asset ||= custom_theme.custom_theme_assets.find(params[:id])
  end
end
