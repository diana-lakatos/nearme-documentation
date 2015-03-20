class InstanceAdmin::Settings::LocalesController < InstanceAdmin::Settings::BaseController
  before_filter :find_locale, except: [:new, :create]

  def new
    @locale = platform_context.instance.locales.new
  end

  def create
    @locale = platform_context.instance.locales.new(locale_params)
    @locale.save ? redirect_to(redirect_url, notice: 'Language has been successfully created') : render('new')
  end

  def edit
  end

  def edit_keys
    @translations = @instance.translations.where(locale: @locale.code)
    @default_translations = Translation.defaults_for 'en'
  end

  def update
    @locale.update_attributes(locale_params) ? redirect_to(redirect_url, notice: 'Language has been successfully updated') : render('edit')
  end

  def destroy
    if @locale.destroy
      redirect_to redirect_url, notice: 'Language has been successfully deleted'
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
