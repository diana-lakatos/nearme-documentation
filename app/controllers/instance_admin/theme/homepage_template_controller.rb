class InstanceAdmin::Theme::HomepageTemplateController < InstanceAdmin::Theme::BaseController
  before_action :find_or_build_homepage_template

  def show
  end

  def update
    update_or_create
  end

  def create
    update_or_create
  end

  private

  def find_or_build_homepage_template
    template_body = File.read(File.join(Rails.root, 'app', 'views', 'home/index.liquid')) rescue nil
    @homepage_template = InstanceView.where("instance_id = ? AND path = 'home/index'", platform_context.instance.id).first ||
      InstanceView.new(path: 'home/index', locale: 'en', format: 'html', handler: 'liquid', partial: 'false', body: template_body)
  end

  def update_or_create
    if @homepage_template.update(template_params.merge("instance_id" => platform_context.instance.id.to_s))
      flash[:success] = t('flash_messages.instance_admin.theme.theme_updated_successfully')
      redirect_to :action => :show
    else
      flash[:error] = @homepage_template.errors.full_messages.to_sentence
      render :show
    end
  end

  def template_params
    params.require(:instance_view).permit(:body)
  end

end
