# frozen_string_literal: true
module Api
  class V3::CustomThemes::InstanceViewsController < BaseController
    include Api::Versionable

    set_resource_method :find_instance_view

    before_action :find_instance_view, except: [:index, :create]

    def index
      render_api_collection(custom_theme.instance_views.custom_theme_views)
    end

    def create
      @instance_view = custom_theme.instance_views.build(instance_view_params)
      @instance_view.format = 'html'
      @instance_view.handler = 'liquid'
      @instance_view.view_type = InstanceView::CUSTOM_VIEW
      @instance_view.instance_id = current_instance.id
      if @instance_view.save
        render_api_object(@instance_view, meta: {
                            redirect: edit_admin_design_custom_theme_instance_view_path(custom_theme, @instance_view)
                          })
      else
        render_api_errors(@instance_view.errors)
      end
    end

    def update
      if @instance_view.update_attributes(instance_view_params)
        render_api_object(@instance_view, meta: {
                            message: t('admin.liquid_views.flash.updated')
                          })
      else
        render_api_errors(@instance_view.errors)
      end
    end

    def destroy
      @instance_view.destroy
      render :nothing, status: 204
    end

    private

    def custom_theme
      @custom_theme ||= CustomTheme.find(params[:custom_theme_id])
    end

    def instance_view_params
      params.require(:instance_view).permit(secured_params.liquid_view)
    end

    def find_instance_view
      @instance_view ||= custom_theme.instance_views.custom_theme_views.find(params[:id])
    end
  end
end
