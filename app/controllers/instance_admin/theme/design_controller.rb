class InstanceAdmin::Theme::DesignController < InstanceAdmin::Theme::BaseController

  before_filter :find_image, :only => [:edit_image, :upload_image, :destroy_image, :update_image]

  def show
    @theme.theme_font || @theme.build_theme_font
  end

  def update
    if @theme.update_attributes(theme_params)
      flash[:success] = t('flash_messages.instance_admin.theme.theme_updated_successfully')
      redirect_to :action => :show
    else
      flash[:error] = @theme.errors.full_messages.to_sentence
      render :show
    end
  end

  def upload_image
    @theme.send("#{params[:image]}_original_url=", params[:url])
    if @theme.save
      render :text => { :url => @theme.send("#{params[:image]}_url"), 
                        :id => params[:image],
                        :resize_url =>  edit_theme_image_instance_admin_theme_design_path(params[:image]),
                        :thumbnail_dimensions => {},
                        :destroy_url => destroy_theme_image_instance_admin_theme_design_path(params[:image]) }.to_json, :content_type => 'text/plain'
    else
      render :text => [{:error => @theme.errors.full_messages}].to_json,:content_type => 'text/plain', :status => 422
    end
  end

  def edit_image
    if request.xhr?
      render partial: 'instance_admin/theme/design/resize_form', 
        :locals => { :form_url => update_theme_image_instance_admin_theme_design_path, 
                     :object => @image, 
                     :object_url => @theme.send("#{params[:image]}_url", :original) }
    end
  end

  def update_image
    @theme.send("#{params[:image]}_transformation_data=", { :crop => params[:crop], :rotate => params[:rotate] })
    if @theme.save
      render partial: 'instance_admin/theme/design/resize_succeeded'
    else
      render partial: 'instance_admin/theme/design/resize_form', 
        :locals => { :form_url => update_theme_image_instance_admin_theme_design_path, 
                     :object => @image, 
                     :object_url => @theme.send("#{params[:image]}_url", :original) }
    end
  end

  def destroy_image
    @theme.send("remove_#{params[:image]}!")
    @theme.save!
    render :text => { success: true, id: params[:image] }, :content_type => 'text/plain', :status => 200
  end

  private

  def find_image
    raise NotImplementedError unless %w(icon_image icon_retina_image favicon_image logo_image logo_retina_image hero_image).include?(params[:image])
    @image = @theme.send(params[:image])
    @image_param = params[:image]
  end
end
