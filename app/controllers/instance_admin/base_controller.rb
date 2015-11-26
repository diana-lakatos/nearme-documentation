class InstanceAdmin::BaseController < ApplicationController
  layout 'instance_admin'

  skip_before_filter :set_locale
  before_filter :auth_user!
  before_filter :authorize_user!
  before_filter :check_if_locked, only: [:new, :create, :edit, :update, :destroy]
  before_filter :force_scope_to_instance
  skip_before_filter :redirect_if_marketplace_password_protected

  ANALYTICS_CONTROLLERS = {
    'overview' => { default_action: 'show' },
    'logs' => { default_action: 'index' }
  }

  REPORTS_CONTROLLERS = {
    'listings' => { default_action: 'index' },
    'products' => { default_action: 'index' },
  }

  MANAGE_CONTROLLERS = {
    'transfers'          => { controller: '/instance_admin/manage/transfers', default_action: 'index' },
    'payments'          => { controller: '/instance_admin/manage/payments', default_action: 'index' },
    'users'              => { controller: '/instance_admin/manage/users', default_action: 'index' },
    'admins'             => { controller: '/instance_admin/manage/admins', default_action: 'index' },
    'partners'           => { controller: '/instance_admin/manage/partners', default_action: 'index' },
    'support'            => { controller: '/instance_admin/manage/support', default_action: 'index' },
    'faq'                => { controller: '/instance_admin/manage/support/faqs', default_action: 'index' },
    'approval_requests'  => { controller: '/instance_admin/manage/approval_requests', default_action: 'index' },
    'waiver_agreements'  => { controller: '/instance_admin/manage/waiver_agreement_templates', default_action: 'index' },
    'email layouts'      => { controller: '/instance_admin/manage/email_layout_templates', default_action: 'index' },
    'emails'             => { controller: '/instance_admin/manage/email_templates', default_action: 'index' },
    'smses'              => { controller: '/instance_admin/manage/sms_templates', default_action: 'index' },
    'workflows'          => { controller: '/instance_admin/manage/workflows', default_action: 'index' },
    'reviews'            => { controller: '/instance_admin/manage/reviews', default_action: 'index' },
    'wish_lists'         => { controller: '/instance_admin/manage/wish_lists', default_action: 'show' },
    'user_profiles'      => { controller: '/instance_admin/manage/instance_profile_types', default_action: 'index' },
    'service_types'      => { controller: '/instance_admin/manage/service_types', default_action: 'index' },
    'upsell_addons'      => { controller: '/instance_admin/manage/upsell_addons', default_action: 'index', title: 'Upsell & Add-ons' },
    'search'             => { controller: '/instance_admin/manage/search', default_action: 'show', title: 'Search' }
  }

  MANAGE_BLOG_CONTROLLERS = {
    'posts' => { default_action: 'index' },
    'user_posts' => { controller: '/instance_admin/manage_blog/user_posts', default_action: 'index' },
    'settings'   => { default_action: 'edit' }
  }

  SETTINGS_CONTROLLERS = {
    'configuration'        => { default_action: 'show' },
    'payments'             => { default_action: 'index' },
    'domains'              => { default_action: 'index' },
    'hidden_controls'      => { default_action: 'show' },
    'locations'            => { default_action: 'show' },
    'listings'             => { default_action: 'show' },
    'integrations'         => { default_action: 'show' },
    'languages'            => { default_action: 'index', controller: '/instance_admin/settings/locales' },
    'documents_upload'     => { default_action: 'show' },
    'seller_attachments'   => { default_action: 'show'},
  }

  THEME_CONTROLLERS = {
    'info'             => { default_action: 'show' },
    'design'           => { default_action: 'show' },
    'homepage'         => { controller: '/instance_admin/theme/homepage_template', default_action: 'show' },
    'homepage content' => { controller: '/instance_admin/theme/homepage', default_action: 'show' },
    'pages'            => { default_action: 'index' },
    'header'           => { default_action: 'show' },
    'footer'           => { default_action: 'show' },
    'content_holders'  => { default_action: 'index' },
    'liquid views'     => { controller: '/instance_admin/theme/liquid_views', default_action: 'index' },
    'file upload'      => { controller: '/instance_admin/theme/file_uploads', default_action: 'index' }
  }

  BUY_SELL_CONTROLLERS = {
    'configuration'  => { default_action: 'show' },
    'commissions'    => { default_action: 'show' },
    'tax_categories' => { default_action: 'index' },
    'tax_rates'      => { default_action: 'index' },
    'zones'          => { default_action: 'index' },
    'product_types'  => { default_action: 'index' }
  }

  SHIPPING_OPTIONS_CONTROLLERS = {
    'dimensions_templates' => { default_action: 'index' },
    'providers' => { default_action: 'show' },
    'shipping_profiles' => { default_action: 'index' },
  }

  PROJECTS_CONTROLLERS = {
    'project_types'  => { default_action: 'index' },
    'projects'   => { default_action: 'index' },
    'topics'  => { default_action: 'index' },
    'spam_reports'  => { default_action: 'index' }
  }

  def index
    redirect_to url_for([:instance_admin, @authorizer.first_permission_have_access_to])
  end

  private

  def check_if_locked
    if PlatformContext.current.instance.locked?
      flash[:notice] = 'You have been redirected because instance is locked, no changes are permitted. All changes have been discarded. You can turn off Master Lock here.'
      redirect_to url_for([:instance_admin, :settings, :configuration])
    end
  end

  def auth_user!
    unless user_signed_in?
      session[:user_return_to] = request.path
      redirect_to instance_admin_login_path
    end
  end

  def authorize_user!
    @authorizer ||= InstanceAdminAuthorizer.new(current_user)
    if !(@authorizer.instance_admin?)
      flash[:warning] = t('flash_messages.authorizations.not_authorized')
      redirect_to root_path
    elsif !@authorizer.authorized?(permitting_controller_class)
      first_permission_have_access_to = @authorizer.first_permission_have_access_to
      if first_permission_have_access_to
        flash[:warning] = t('flash_messages.authorizations.not_authorized')
        redirect_to url_for([:instance_admin, first_permission_have_access_to])
      else
        redirect_to root_path
      end
    end
  rescue InstanceAdminAuthorizer::UnassignedInstanceAdminRoleError => e
    ExceptionTracker.track_exception(e)
    flash[:warning] = t('flash_messages.authorizations.not_authorized')
    redirect_to root_path
  end

  def permitting_controller_class
    self.class.to_s.deconstantize.demodulize
  end

  def instance_admin_roles
    @instance_admin_roles ||= InstanceAdminRole.all
  end
  helper_method :instance_admin_roles

  def append_to_breadcrumbs(title, url = nil)
    if @breadcrumbs_title.kind_of?(BreadcrumbsList)
      @breadcrumbs_title.append_location(title, url)
    else
      @breadcrumbs_title = title
    end
  end

end
