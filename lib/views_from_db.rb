# frozen_string_literal: true
module ViewsFromDb
  extend ActiveSupport::Concern

  included do
    before_action :prepend_view_paths
    before_action :set_i18n_locale
    before_action :register_platform_context_as_lookup_context_detail

    protected

    def register_lookup_context_detail(detail_name)
      lookup_context.class.register_detail(detail_name.to_sym) { nil }
    end

    def register_platform_context_as_lookup_context_detail
      register_lookup_context_detail(:instance_id)
      register_lookup_context_detail(:i18n_locale)
      register_lookup_context_detail(:transactable_type_id)
      register_lookup_context_detail(:custom_theme_id)
    end

    def assign_transactable_type_id_to_lookup_context(&_block)
      lookup_context.transactable_type_id ||= @transactable_type.try(:id)
    end

    def prepend_view_paths
      prepend_view_path("app/#{custom_view_path}_views") if custom_view_path.present?
      prepend_view_path InstanceViewResolver.instance
      prepend_view_path(ENV['MARKETPLACE_VIEW']) if ENV['MARKETPLACE_VIEW'].present? && Rails.env.development?
    end

    def custom_view_path
      # FIXME: tmp hack to fallback to 'intel' for is community
      if PlatformContext.current.instance.is_community?
        PlatformContext.current.instance.prepend_view_path.presence || 'devmesh'
      else
        PlatformContext.current.instance.prepend_view_path
      end
    end

    def details_for_lookup
      PlatformContext.current.overwrite_custom_theme(current_user)
      set_i18n_locale if @language_service.nil? && !Rails.env.test?
      {
        instance_id: PlatformContext.current.try(:instance).try(:id),
        i18n_locale: I18n.locale,
        custom_theme_id: PlatformContext.current.try(:custom_theme).try(:id),
        transactable_type_id: @transactable_type.try(:id) || (params[:transactable_type_id].present? ? (TransactableType.find_by(slug: params[:transactable_type_id]).try(:id) || params[:transactable_type_id]).to_i : nil)
      }
    rescue
      {
        instance_id: PlatformContext.current.try(:instance).try(:id),
        i18n_locale: I18n.locale,
        custom_theme_id: PlatformContext.current.try(:custom_theme).try(:id)
      }
    end

    def set_i18n_locale
      I18n.locale = language_service.get_language
      session[:language] = I18n.locale
    end

    def language_router
      @language_router ||= if language_service.available_languages.many?
                             Language::MultiLanguageRouter.new(params[:language], I18n.locale)
                           else
                             Language::SingleLanguageRouter.new(params[:language])
                           end
    end

    def language_service
      @language_service ||= Language::LanguageService.new(
        language_params,
        fallback_languages,
        current_instance.available_locales
      )
    end

    def language_params
      [params[:language]]
    end

    def fallback_languages
      [
        session[:language],
        current_user.try(:language),
        current_instance.try(:primary_locale),
        I18n.default_locale
      ]
    end

    def language_url_option
      PlatformContext.current&.url_locale
    end

    # This method invalidates default PlatformContext and ensures that our scope is Instance [ disregarding listings_public for relevant models ].
    # It should be used whenever we don't want default scoping based on domain for some part of app. That's the case for example for
    # instance_admin (for example we want instance admins to be able to access administrator panel via any white label company ), dashboard (we
    # want white label company creator to manage its private company via instance domain ). Remember, that if this method is used, we are no
    # longer scoping for white label / partner. It means, we should manually ensure we scope correctly ( for example in Dashboard ).
    def force_scope_to_instance
      PlatformContext.scope_to_instance
    end
  end
end
