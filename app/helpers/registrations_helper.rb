module RegistrationsHelper
  def build_link_for(provider, class_for_links)
    if (authentication = Authentication.find_by(provider: provider.downcase, user_id: current_user.id))
      # authentication already exists in the database
      class_for_links += ' connected'
      class_for_links += ' provider-not-disconnectable' unless authentication.can_be_deleted?
      link_to authentication_path(authentication), method: :delete, class: class_for_links do
        content_tag(:span, t('registrations.social_accounts.disconnect'), class: "padding ico-#{provider.downcase}")
      end
    else
      # user is not connected to this social provider yet - no authentication in the database
      link_to provider_auth_url(provider.downcase), class: class_for_links do
        content_tag(:span, t('registrations.social_accounts.connect'), class: "padding ico-#{provider.downcase}")
      end
    end
  end

  def active_profile_tab_class(name)
    default = ''
    name = name.to_sym
    active_class = 'active'

    param_tab = params[:tab]
    tabs = %w(general services reviews blog_posts)

    services_conditions = params[:services_page].present? && name == :services && param_tab.nil?
    general_conditions = name == :general && params[:services_page].blank? && !tabs.include?(param_tab)

    return active_class if (param_tab.to_s == name.to_s) || services_conditions || general_conditions

    default
  end
end
