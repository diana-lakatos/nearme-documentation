class Admin::PlatformHomeController < Admin::BaseController

  def edit
    @views = InstanceView.where("path like ?", "%platform_home%")
  end

  def update
    @views = params[:instance][:instance_views_attributes]

    @views.each do |k, v|
      view = InstanceView.find(v['id'])

      if view.update_attributes(body: v['body'])
        flash[:success] = "Platform Home views updated successfully."
      else
        flash[:error] = "Failed to update Platform Home views."
      end
    end
  end

end

