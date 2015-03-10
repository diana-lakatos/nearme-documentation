class InstanceAdmin::Theme::FooterController < InstanceAdmin::Theme::BaseController
  before_action :find_or_build_template

  def show
  end

  def update
    update_or_create
  end

  def create
    update_or_create
  end

  private

  def find_or_build_template
    template_body = File.read(File.join(Rails.root, 'app', 'views', 'layouts/_theme_footer.html.liquid')) rescue nil

    @template = InstanceView.find_or_initialize_by(instance_id: platform_context.instance.id, path: 'layouts/theme_footer') do |view|
      view.locale = 'en'
      view.format = 'html'
      view.handler = 'liquid'
      view.partial = 'true'
      view.body = template_body
    end
  end

  def update_or_create
    if @template.update(template_params.merge("instance_id" => platform_context.instance.id.to_s))
      flash[:success] = t('flash_messages.instance_admin.theme.theme_updated_successfully')
      redirect_to :action => :show
    else
      flash[:error] = @template.errors.full_messages.to_sentence
      render :show
    end
  end

  def template_params
    params.require(:instance_view).permit(:body)
  end

end
