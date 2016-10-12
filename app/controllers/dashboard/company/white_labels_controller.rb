class Dashboard::Company::WhiteLabelsController < Dashboard::Company::BaseController
  before_filter :find_or_create_theme, only: [:upload_image, :edit_image, :update_image, :destroy_image]
  before_filter :find_image, only: [:upload_image, :edit_image, :update_image, :destroy_image]

  def edit
  end

  def update
    if @company.update_attributes(company_params)
      flash[:success] = t('flash_messages.manage.companies.white_label_updated')
      redirect_to edit_dashboard_company_white_label_path(@company.id)
    else
      render :edit
    end
  end

  def upload_image
    @theme.send("#{@image_param}=", params[:image_data])
    if @theme.save
      render text: {
        url: @theme.send("#{@image_param}_url"),
        id: @image_param,
        resize_url: edit_theme_image_dashboard_company_white_label_path(image: @image_param),
        thumbnail_dimensions: {},
        destroy_url: destroy_theme_image_dashboard_company_white_label_path(image: @image_param)
      }.to_json, content_type: 'text/plain'
    else
      render text: [{ error: @theme.errors.full_messages }].to_json, content_type: 'text/plain', status: 422
    end
  end

  def edit_image
    if request.xhr?
      render partial: 'dashboard/photos/resize_form', locals: { form_url: update_theme_image_dashboard_company_white_label_path(image: @image_param), object: @image, object_url: @theme.send("#{@image_param}_url", :original) }
    end
  end

  def update_image
    @theme.send("#{@image_param}_transformation_data=", crop: params[:crop], rotate: params[:rotate])
    if @theme.save
      render partial: 'dashboard/photos/resize_succeeded'
    else
      render partial: 'dashboard/photos/resize_form', locals: { form_url: update_theme_image_dashboard_company_white_label_path(image: @image_param), object: @image, object_url: @theme.send("#{@image_param}_url", :original) }
    end
  end

  def destroy_image
    @theme.send("remove_#{@image_param}!")
    @theme.save
    render text: { success: true, id: @image_param }, content_type: 'text/plain', status: 200
  end

  private

  def company_params
    params.require(:company).permit(secured_params.company)
  end

  def find_company
    @company = params[:id].try(:kind_of?, Integer) ? current_user.companies.find(params[:id]) : current_user.companies.first
  end

  def find_or_create_theme
    @theme = @company.theme
    if @theme.nil?
      @theme = @company.build_theme
      @theme.save
    end
  end

  def find_image
    fail NotImplementedError unless %w(icon_image icon_retina_image favicon_image logo_image logo_retina_image hero_image).include?(params[:image])
    @image = @theme.send(params[:image])
    @image_param = params[:image]
  end
end
