class InstanceAdmin::ThemesController < InstanceAdmin::BaseController
  before_action :find_theme, :find_image

  def upload_image
    @theme.send("#{params[:image]}=", params[:image_data])
    if @theme.save
      render text: {
        url: @theme.send("#{params[:image]}_url"),
        id: params[:image],
        resize_url:  edit_image_instance_admin_theme_path(params[:id], params[:image]),
        thumbnail_dimensions: {},
        destroy_url: destroy_image_instance_admin_theme_path(params[:id], params[:image])
      }.to_json, content_type: 'text/plain'
    else
      render text: [{ error: @theme.errors.full_messages }].to_json, content_type: 'text/plain', status: 422
    end
  end

  def edit_image
    if request.xhr?
      render partial: 'instance_admin/theme/design/resize_form',
             locals: { form_url: update_image_instance_admin_theme_path(params[:id], params[:image]),
                       object: @image,
                       object_url: @theme.send("#{params[:image]}_url", :original) }
    end
  end

  def update_image
    @theme.send("#{params[:image]}_transformation_data=", crop: params[:crop], rotate: params[:rotate])
    if @theme.save
      render partial: 'instance_admin/theme/design/resize_succeeded'
    else
      render partial: 'instance_admin/theme/design/resize_form',
             locals: { form_url: update_theme_image_instance_admin_theme_design_path(params[:id]),
                       object: @image,
                       object_url: @theme.send("#{params[:image]}_url", :original) }
    end
  end

  def destroy_image
    @theme.send("remove_#{params[:image]}!")
    @theme.save!
    render text: { success: true, id: params[:image] }, content_type: 'text/plain', status: 200
  end

  private

  def find_theme
    @theme = Theme.find(params[:id])
    theme_instance_id = @theme.owner.is_a?(Instance) ? @theme.owner_id : @theme.owner.instance_id
    fail ArgumentError unless platform_context.instance.id == theme_instance_id
  end

  def find_image
    fail NotImplementedError unless %w(icon_image icon_retina_image favicon_image logo_image logo_retina_image hero_image).include?(params[:image])
    @image = @theme.send(params[:image])
    @image_param = params[:image]
  end
end
