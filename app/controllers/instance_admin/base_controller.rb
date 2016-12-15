# frozen_string_literal: true
class InstanceAdmin::BaseController < ApplicationController
  layout 'instance_admin'

  skip_before_action :redirect_unverified_user
  skip_before_action :set_locale
  before_action :auth_user!
  before_action :authorize_user!
  before_action :check_if_locked, only: [:new, :create, :edit, :update, :destroy]
  before_action :force_scope_to_instance
  skip_before_action :redirect_if_marketplace_password_protected

  ANALYTICS_CONTROLLERS = {
    'overview' => { default_action: 'show' },
    'logs' => { default_action: 'index' }
  }.freeze

  REPORTS_CONTROLLERS = {
    'transactables' => { default_action: 'index', title: 'Listings' },
    'users'         => { default_action: 'index' }
  }.freeze

  COMMUNITY_REPORTS_CONTROLLERS = {
    'projects' => { default_action: 'index' },
    'advanced_projects' => { default_action: 'index' }
  }.freeze

  MANAGE_CONTROLLERS = {
    'transfers'          => { controller: '/instance_admin/manage/transfers', default_action: 'index' },
    'payments'           => { controller: '/instance_admin/manage/payments', default_action: 'index' },
    'webhooks'           => { controller: '/instance_admin/manage/webhooks', default_action: 'index' },
    'orders'             => { controller: '/instance_admin/manage/orders', default_action: 'index' },
    'merchants'          => { controller: '/instance_admin/manage/merchant_accounts', default_action: 'index' },
    'users'              => { controller: '/instance_admin/manage/users', default_action: 'index' },
    'admins'             => { controller: '/instance_admin/manage/admins', default_action: 'index' },
    'partners'           => { controller: '/instance_admin/manage/partners', default_action: 'index' },
    'approval_requests'  => { controller: '/instance_admin/manage/approval_requests', default_action: 'index' },
    'waiver_agreements'  => { controller: '/instance_admin/manage/waiver_agreement_templates', default_action: 'index' },
    'email layouts'      => { controller: '/instance_admin/manage/email_layout_templates', default_action: 'index' },
    'emails'             => { controller: '/instance_admin/manage/email_templates', default_action: 'index' },
    'smses'              => { controller: '/instance_admin/manage/sms_templates', default_action: 'index' },
    'workflows'          => { controller: '/instance_admin/manage/workflows', default_action: 'index' },
    'reviews'            => { controller: '/instance_admin/manage/reviews', default_action: 'index' },
    'wish_lists'         => { controller: '/instance_admin/manage/wish_lists', default_action: 'show' },
    'user_profiles'      => { controller: '/instance_admin/manage/instance_profile_types', default_action: 'index' },
    'location'           => { controller: '/instance_admin/manage/location', default_action: 'show' },
    'transactable_types' => { controller: '/instance_admin/manage/transactable_types', default_action: 'index' },
    'reservation_types'  => { controller: '/instance_admin/manage/reservation_types', default_action: 'index' },
    'custom_validators'  => { controller: '/instance_admin/manage/custom_validators', default_action: 'index', title: 'Custom Validators' },
    'categories'         => { controller: '/instance_admin/manage/categories', default_action: 'index', title: 'Categories' },
    'custom_models'      => { controller: '/instance_admin/manage/custom_model_types', default_action: 'index', title: 'Custom Models' },
    'upsell_addons'      => { controller: '/instance_admin/manage/additional_charge_types', default_action: 'index', title: 'Upsell & Add-ons' },
    'search'             => { controller: '/instance_admin/manage/search', default_action: 'show', title: 'Search' }
  }.freeze

  MANAGE_BLOG_CONTROLLERS = {
    'posts' => { default_action: 'index' },
    'user_posts' => { controller: '/instance_admin/manage_blog/user_posts', default_action: 'index' },
    'settings'   => { default_action: 'edit' }
  }.freeze

  SETTINGS_CONTROLLERS = {
    'configuration'        => { default_action: 'show', controller_class: 'InstanceAdmin::Settings::ConfigurationController' },
    'payments'             => { default_action: 'index' },
    'shipping_providers'   => { default_action: 'index', title: 'Shipping providers', controller: '/instance_admin/settings/shippings/shipping_providers' },
    'domains'              => { default_action: 'index' },
    'ssl_certificates'     => { default_action: 'index', title: 'SSL Certificates', controller: '/instance_admin/settings/aws_certificates' },
    'api_keys'             => { default_action: 'index' },
    'hidden_controls'      => { default_action: 'show' },
    'locations'            => { default_action: 'show' },
    'integrations'         => { default_action: 'show' },
    'languages'            => { default_action: 'index', controller: '/instance_admin/settings/locales' },
    'documents_upload'     => { default_action: 'show' },
    'seller_attachments'   => { default_action: 'show' },
    'taxes'                => { default_action: 'index', controller: '/instance_admin/settings/tax_regions' }
  }.freeze

  THEME_CONTROLLERS = {
    'info'                   => { default_action: 'show' },
    'design'                 => { default_action: 'show' },
    'pages'                  => { default_action: 'index' },
    'content_holders'        => { default_action: 'index' },
    'liquid views'           => { controller: '/instance_admin/theme/liquid_views', default_action: 'index' },
    'file upload'            => { controller: '/instance_admin/theme/file_uploads', default_action: 'index' },
    'photo_uploads'          => { controller: '/instance_admin/theme/photo_upload_versions', default_action: 'index', title: 'Photo Uploads' },
    'default_images'         => { controller: '/instance_admin/theme/default_images', default_action: 'index', title: 'Default Images' },
    'graph queries'          => { controller: '/instance_admin/theme/graph_queries', default_action: 'index' }
  }.freeze

  SHIPPING_OPTIONS_CONTROLLERS = {
    'dimensions_templates' => { default_action: 'index' },
    'providers' => { default_action: 'show' },
    'shipping_profiles' => { default_action: 'index' }
  }.freeze

  SUPPORT_CONTROLLERS = {
    'tickets' => { controller: '/instance_admin/support/support', default_action: 'index' },
    'faq'     => { controller: '/instance_admin/support/faqs', default_action: 'index' }
  }.freeze

  PROJECTS_CONTROLLERS = {
    'transactable_types' => { default_action: 'index', title: 'Project Types' },
    'projects' => { default_action: 'index' },
    'topics' => { default_action: 'index' },
    'spam_reports'  => { default_action: 'index' }
  }.freeze

  CUSTOM_TEMPLATES_CONTROLLERS = {
    'custom_themes' => { default_action: 'index' }
  }.freeze

  GROUPS_CONTROLLERS = {
    'group_types' => { default_action: 'index' },
    'groups' => { default_action: 'index' }
  }.freeze

  PERMISSIONS_CONTROLLERS = {
    blog: 'manage_blog',
    support: 'support_root',
    buysell: 'buy_sell',
    customtemplates: 'custom_templates',
    shippingoptions: %w(shipping_options shipping_profiles),
    reports: %w(reports listings)
  }.with_indifferent_access

  def index
    first_permission = @authorizer.first_permission_have_access_to

    if PERMISSIONS_CONTROLLERS.key?(first_permission)
      redirect_to url_for([:instance_admin, PERMISSIONS_CONTROLLERS[first_permission]].flatten)
    else
      redirect_to url_for([:instance_admin, first_permission])
    end
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
    if !@authorizer.instance_admin?
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
    if @breadcrumbs_title.is_a?(BreadcrumbsList)
      @breadcrumbs_title.append_location(title, url)
    else
      @breadcrumbs_title = title
    end
  end
end
