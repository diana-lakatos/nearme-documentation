class InstanceAdmin::Settings::LocalesController < InstanceAdmin::Settings::BaseController
  before_filter :find_locale, except: [:index, :new, :create]

  def index
    @locales = Locale.order('created_at')
  end

  def new
    @locale = platform_context.instance.locales.build
  end

  def create
    @locale = platform_context.instance.locales.new(locale_params)

    if @locale.save
      flash[:success] = t 'flash_messages.instance_admin.settings.locales.created'
      redirect_to redirect_url
    else
      render 'new'
    end
  end

  def edit
  end

  def edit_keys
    @translations = @instance.translations.where(locale: @locale.code)
    @default_translations = Translation.defaults_for 'en'
  end

  def update
    if @locale.update_attributes(locale_params)
      flash[:success] = t 'flash_messages.instance_admin.settings.locales.updated'
      redirect_to redirect_url
    else
      render 'edit'
    end
  end

  def destroy
    if @locale.destroy
      flash[:success] = t 'flash_messages.instance_admin.settings.locales.deleted'
      redirect_to redirect_url
    else
      flash[:error] = @locale.errors.full_messages.to_sentence
      redirect_to redirect_url
    end
  end

  private

  def redirect_url
    instance_admin_settings_translations_path
  end

  def find_locale
    @locale = platform_context.instance.locales.find(params[:id])
  end

  def locale_params
    params.require(:locale).permit(secured_params.locale)
  end
end
