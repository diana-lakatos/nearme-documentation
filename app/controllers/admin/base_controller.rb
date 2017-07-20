# frozen_string_literal: true
class Admin::BaseController < ApplicationController
  layout 'admin/default'

  skip_before_action :set_locale
  before_action :auth_user!
  before_action :authorize_user!
  before_action :check_if_locked, only: [:new, :create, :edit, :update, :destroy]
  before_action :force_scope_to_instance
  skip_before_action :redirect_if_marketplace_password_protected

  # ANALYTICS_CONTROLLERS = {
  #   'overview' => { default_action: 'show' },
  #   'logs' => { default_action: 'index' }
  # }.freeze

  # REPORTS_CONTROLLERS = {
  #   'transactables' => { default_action: 'index', title: 'Listings' },
  #   'products'      => { default_action: 'index' },
  #   'offers'        => { default_action: 'index' },
  #   'users'         => { default_action: 'index' }
  # }.freeze

  # COMMUNITY_REPORTS_CONTROLLERS = {
  #   'projects' => { default_action: 'index' },
  #   'advanced_projects' => { default_action: 'index' }
  # }.freeze

  # MANAGE_CONTROLLERS = {
  #   'transfers'          => { controller: '/admin/manage/transfers', default_action: 'index' },
  #   'payments'           => { controller: '/admin/manage/payments', default_action: 'index' },
  #   'merchants'          => { controller: '/admin/manage/merchant_accounts', default_action: 'index' },
  #   'users'              => { controller: '/admin/manage/users', default_action: 'index' },
  #   'admins'             => { controller: '/admin/manage/admins', default_action: 'index' },
  #   'partners'           => { controller: '/admin/manage/partners', default_action: 'index' },
  #   'approval_requests'  => { controller: '/admin/manage/approval_requests', default_action: 'index' },
  #   'waiver_agreements'  => { controller: '/admin/manage/waiver_agreement_templates', default_action: 'index' },
  #   'email layouts'      => { controller: '/admin/manage/email_layout_templates', default_action: 'index' },
  #   'emails'             => { controller: '/admin/manage/email_templates', default_action: 'index' },
  #   'smses'              => { controller: '/admin/manage/sms_templates', default_action: 'index' },
  #   'workflows'          => { controller: '/admin/manage/workflows', default_action: 'index' },
  #   'reviews'            => { controller: '/admin/manage/reviews', default_action: 'index' },
  #   'wish_lists'         => { controller: '/admin/manage/wish_lists', default_action: 'show' },
  #   'user_profiles'      => { controller: '/admin/manage/instance_profile_types', default_action: 'index' },
  #   'location'           => { controller: '/admin/manage/location', default_action: 'show' },
  #   'service_types'      => { controller: '/admin/manage/service_types', default_action: 'index' },
  #   'offer_types'        => { controller: '/admin/manage/offer_types', default_action: 'index' },
  #   'reservation_types'  => { controller: '/admin/manage/reservation_types', default_action: 'index' },
  #   'custom_validators'  => { controller: '/admin/manage/custom_validators', default_action: 'index', title: 'Custom Validators' },
  #   'categories'         => { controller: '/admin/manage/categories', default_action: 'index', title: 'Categories' },
  #   'custom_models'      => { controller: '/admin/manage/custom_model_types', default_action: 'index', title: 'Custom Models' },
  #   'upsell_addons'      => { controller: '/admin/manage/additional_charge_types', default_action: 'index', title: 'Upsell & Add-ons' },
  #   'search'             => { controller: '/admin/manage/search', default_action: 'show', title: 'Search' }
  # }.freeze

  # MANAGE_BLOG_CONTROLLERS = {
  #   'posts' => { default_action: 'index' },
  #   'user_posts' => { controller: '/admin/manage_blog/user_posts', default_action: 'index' },
  #   'settings'   => { default_action: 'edit' }
  # }.freeze

  # SETTINGS_CONTROLLERS = {
  #   'configuration'        => { default_action: 'show', controller_class: 'InstanceAdmin::Settings::ConfigurationController' },
  #   'payments'             => { default_action: 'index' },
  #   'domains'              => { default_action: 'index' },
  #   'hidden_controls'      => { default_action: 'show' },
  #   'locations'            => { default_action: 'show' },
  #   'listings'             => { default_action: 'show' },
  #   'integrations'         => { default_action: 'show' },
  #   'languages'            => { default_action: 'index', controller: '/admin/settings/locales' },
  #   'documents_upload'     => { default_action: 'show' },
  #   'seller_attachments'   => { default_action: 'show' },
  #   'taxes'                => { default_action: 'index', controller: '/admin/settings/tax_regions' },
  #   'ui_settings'          => { default_action: 'index', controller: '/admin/ui_settings' }
  # }.freeze

  # THEME_CONTROLLERS = {
  #   'info'             => { default_action: 'show' },
  #   'design'           => { default_action: 'show' },
  #   'pages'            => { default_action: 'index' },
  #   'content_holders'  => { default_action: 'index' },
  #   'liquid views'     => { controller: '/admin/theme/liquid_views', default_action: 'index' },
  #   'file upload'      => { controller: '/admin/theme/file_uploads', default_action: 'index' }
  # }.freeze

  # BUY_SELL_CONTROLLERS = {
  #   'configuration'  => { default_action: 'show', controller_class: 'InstanceAdmin::BuySell::ConfigurationController' },
  #   'commissions'    => { default_action: 'show' },
  #   'tax_categories' => { default_action: 'index' },
  #   'tax_rates'      => { default_action: 'index' },
  #   'zones'          => { default_action: 'index' },
  #   'product_types'  => { default_action: 'index' }
  # }.freeze

  # SHIPPING_OPTIONS_CONTROLLERS = {
  #   'dimensions_templates' => { default_action: 'index' },
  #   'providers' => { default_action: 'show' },
  #   'shipping_profiles' => { default_action: 'index' }
  # }.freeze

  # SUPPORT_CONTROLLERS = {
  #   'tickets' => { controller: '/admin/support/support', default_action: 'index' },
  #   'faq'     => { controller: '/admin/support/faqs', default_action: 'index' }
  # }.freeze

  # PROJECTS_CONTROLLERS = {
  #   'project_types' => { default_action: 'index' },
  #   'projects' => { default_action: 'index' },
  #   'topics' => { default_action: 'index' },
  #   'spam_reports' => { default_action: 'index' }
  # }.freeze

  PERMISSIONS_CONTROLLERS = {
    blog: 'manage_blog',
    support: 'support_root',
    buysell: 'buy_sell',
    shippingoptions: %w(shipping_options shipping_profiles),
    reports: %w(reports listings)
  }.with_indifferent_access

  def index
    first_permission = @authorizer.first_permission_have_access_to

    if PERMISSIONS_CONTROLLERS.key?(first_permission)
      redirect_to url_for([:admin, PERMISSIONS_CONTROLLERS[first_permission]].flatten)
    else
      redirect_to url_for([:admin, first_permission])
    end
  end

  private

  def check_if_locked
    if PlatformContext.current.instance.locked?
      flash[:notice] = 'You have been redirected because instance is locked, no changes are permitted. All changes have been discarded. You can turn off Master Lock here.'
      redirect_to url_for([:admin, :settings, :configuration])
    end
  end

  def auth_user!
    unless user_signed_in?
      session[:user_return_to] = request.path
      redirect_to admin_login_path
    end
  end

  def authorize_user!
    # To avoid errors and confusion until the new admin is ready we redirect non-global-admin users to the actual
    # admin interface
    # if !current_user.admin? && Rails.env.production?
    #  redirect_to instance_admin_path
    #  return
    # end

    @authorizer ||= InstanceAdminAuthorizer.new(current_user)
    if !@authorizer.instance_admin?
      flash[:warning] = t('flash_messages.authorizations.not_authorized')
      redirect_to root_path
    elsif !@authorizer.authorized?(permitting_controller_class)
      first_permission_have_access_to = @authorizer.first_permission_have_access_to
      if first_permission_have_access_to
        flash[:warning] = t('flash_messages.authorizations.not_authorized')
        redirect_to url_for([:admin, first_permission_have_access_to])
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
    if @breadcrumbs_title.is_a?(BreadcrumbsList)
      @breadcrumbs_title.append_location(title, url)
    else
      @breadcrumbs_title = title
    end
  end
end
