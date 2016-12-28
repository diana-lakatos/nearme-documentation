# frozen_string_literal: true
module Api
  class V3::InstanceViewsController < BaseController
    include Api::Versionable

    set_resource_method :find_instance_view

    before_action :find_instance_view, except: [:index, :create]

    def show
      render_api_object(@instance_view)
    end

    def create
      @instance_view = platform_context.instance.instance_views.build(instance_view_params)
      @instance_view.format = 'html'
      @instance_view.handler = 'liquid'
      @instance_view.view_type = InstanceView::VIEW_VIEW
      if @instance_view.save
        render_api_object(@instance_view, meta: {
                            redirect: url_for([:edit, :admin, :design, @instance_view])
                          })
      else
        render_api_errors(@instance_view.errors)
      end
    end

    def update
      # do not allow to change path for now
      params[:instance_view][:path] = @instance_view.path
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

    def instance_view_params
      params.require(:instance_view).permit(secured_params.liquid_view)
    end

    def find_instance_view
      @instance_view ||= platform_context.instance.instance_views.liquid_views.find(params[:id])
    end
  end
end
