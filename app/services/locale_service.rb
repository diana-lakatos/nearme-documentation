class LocaleService

  attr_reader :redirect_url
  attr_reader :locale

  def initialize(instance, params_locale, user_locale, requested_path)
    @params_locale = params_locale.try(:to_sym)
    @user_locale = user_locale.try(:to_sym)
    @requested_path = requested_path

    @primary_locale = instance.primary_locale
    @params_locale_exists = instance.locales.find_by(code: @params_locale.to_s)

    @redirect_url = nil
    @locale = nil

    process
  end

  def redirect?
    @redirect_url.present?
  end

  private

  # @params_locale => locale taken from URL itself
  # @user_locale => locale taken from User.language
  #
  # 1) Redirect if @user_locale is different than @params_locale
  # 2) Redirect if @user_locale is different than @primary_locale and no @params_locale is given
  # 3) Not redirect if @params_locale == @user_locale
  # 4) Redirect if @params_locale does not exist on instance
  # 5) Redirect if @params_locale is same as @primary_locale on instance
  def process
    if @user_locale.present?
      @locale = @user_locale

      if @params_locale.present? && @user_locale != @params_locale
        @redirect_url = url_with_locale(@user_locale)
        return
      end

      if @params_locale.blank? && @user_locale != @primary_locale
        @redirect_url = url_with_locale(@user_locale)
        return
      end

    end

    # Redirect if param_locale is the same as the primary locale or param_locale does not exist
    if @params_locale.present? && (@params_locale == @primary_locale || !@params_locale_exists)
      @redirect_url = url_without_locale
      @locale = @primary_locale
      return
    end

    @params_locale = @user_locale if @params_locale.blank? && @user_locale.present?

    # Set either primary or requested language
    @locale = @params_locale.present? ? @params_locale : @primary_locale
  end

  def url_without_locale
    path = @requested_path
    Locale.remove_locale_from_url(path)
    path
  end

  def url_with_locale(locale)
    path = @requested_path
    Locale.change_locale_in_url(path, locale.to_s)
    path
  end
end
