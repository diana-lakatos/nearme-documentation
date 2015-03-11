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
    @homepage_template = InstanceView.find_or_initialize_by(instance_id: platform_context.instance.id, path: 'home/index') do |view|
      view.locale = 'en'
      view.format = 'html'
      view.handler = 'liquid'
      view.partial = 'false'
      view.body = File.read(File.join(Rails.root, 'app', 'views', 'home/index.liquid')) rescue nil
    end
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
