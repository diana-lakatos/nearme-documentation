class InstanceAdmin::Settings::ConfigurationController < InstanceAdmin::Settings::BaseController
  skip_before_filter :check_if_locked, only: :lock

  def update
    if params[:validate_imap_settings_button]
      validate_imap_settings
    else
      super
      if @instance.valid?
        update_relevant_translations
      end
    end
  end

  def lock
    if @instance.update_attributes(instance_params)
      flash[:success] = t('flash_messages.instance_admin.settings.settings_updated')
      redirect_to action: :show
    else
      flash[:error] = @instance.errors.full_messages.to_sentence
      redirect_to action: :show
    end
  end

  protected

  def validate_imap_settings
    isv = ImapSettingsValidator.new(PlatformContext.current.instance)
    if isv.validate_settings
      flash[:success] = t('flash_messages.instance_admin.imap_settings.validation_successful')
      redirect_to action: :show
    else
      flash[:error] = t('flash_messages.instance_admin.imap_settings.could_not_validate')
      redirect_to action: :show
    end
  end

  def update_relevant_translations
    return unless params[:instance][:translations]
    %w(buy_sell_market.checkout.manual_payment buy_sell_market.checkout.manual_payment_description).each do |key|
      t = Translation.where(instance_id: PlatformContext.current.instance.id, key: key, locale: I18n.locale).first_or_initialize
      t.update_attribute(:value, params[:instance][:translations][key])
    end
  end

end

