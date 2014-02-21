# Module responsible for scoping based on current PlatformContext.
#
# This module adds default_scope to models that invoke scoped_to_platform_context method. There are three main scenarios:
#  1) platform context is instance
#
#   In this case, we would like to add WHERE('models.instance_id = ?', <instance_id>) to all queries. This assumes that model
#   has already instance_id column in db. All white label companies have possibility to say, that they want their listings to be private, meaning 
#   they want them to be accessible only via their domain. That's why we want to also add WHERE('models.listings_public = ?', true) to models that support this 
#   setting.
#
#  2) platform context is a partner
#
#   There are two possibilities here.
#
#   a) partner has scoping enabled [ partner.search_scope_option == 'all_associated_listings' ]
#   In this case we want to add WHERE('models.partner_id = ?', <partner_id) to all queries. This will be applied only to models that have
#   column partner_id. If they don't have it, we assume that model should not be scoped to partner and then we just add query for instance_id 
#   instead ( This is the case for example for AmenityType, ListingType, LocationType etc. - they are shared between partners). 
#   We also want to scope to listings_public = true where appropriate.
#
#   b) partner has scoping disabled [ partner.search_scope_option == 'no_scoping' ]
#   In this case we just use partner for different theme, but we don't want to provide additional scoping. It means, we want to scope only to instance to which partner
#   belongs, i.e. WHERE('models.instance_id = ? AND listings_public = ?', <partner.instance_id>, true). We also want to scope to listings_public = true where appropriate.
#
#  3) platform context is a white label company
#
#  We want to add WHERE('models.company_id = ?', <company_id>) to models that have company_id column in db. Other models we want to scope to instance. We don't
#  set any constraint on listings_public in this case, because it's not needed - we are on white label company and all models that have listings_enabled column,
#  have also company_id column [ exception is Company - in which case we scope to its id instead of company_id ]
#
#  This scoping is default. There are few exceptions though.
#
#  1) Some models might have 'global' version, where instance_id is nil. For example, InstanceAdminRole model have two global rows that should be shared
#  between instances - administrator role and default role. that's why there is option :allow_nil => true that can be passed to allow nil.
#
#  2) In some parts of app, we don't want default scoping. For example, in our admin, we actually don't want any scoping at all - we want access to everything. This is done
#  by manually setting PlatformContext.current to nil.
#
#  3) In instance admin we want to have access to everything related to instance, ignoring listings_public settings etc. To do this, we just need to add in controller in a before filter
#  PlatformContext.scope_to_instance . This will make PlatformContext.scoped_to_instance? return true, and we will just add WHERE('models.instance_id = ?', <instance_id>) no matter
#  if we are on white label company domain, partner domain and no matter if models respond to listings_public.
#
#  4) Similary in dashboard, we want to force instance scope via PlatformContext.scope_to_instance. There is an edge case for default scoping: 
#  if logged in user has created white label company with listings_public = false, and he enters instance domain, by default we scope to listings_public = true, 
#  meaning he wouldn't be able to change his settings via instance domain. To allow him to do this, we scope to company in dashboard manually.

#  Usage:
#
#  add scoped_to_platform_context to model, for example
#
#  Listing.rb
#  scoped_to_platform_context
#
#  Method takes as argument options hash, with keys:
#  :allow_nil - boolean (default false). If it is set to true, then instance_id will be allowed to be nil. Important for example for InstanceAdminRole
#               which have two records (Administrator and Default) which should be shared between instances. Remember to not allow any instance_admin
#               to edit/destroy it! Also remember that instance admins should not be allowed to create global objects!

module PlatformContext::DefaultScoper
  extend ActiveSupport::Concern

  included do

    def self.scoped_to_platform_context(options = {})
      if self.table_exists?
        class_eval <<-EOV
          default_scope lambda { self.platform_context_default_scope }

          def self.platform_context_default_scope
            #{DefaultScopeBuilder.new(self, options).build_default_scope.join("\n")}
          end
        EOV
      end
    end

  end

  protected

  # Class responsible for building default scope based on class and options passed
  #
  # For example, LocaionType model should be scoped onyl for instance_id, while Listing
  # has much more complex scoping logic - it is scoped to white label company and/or partner and/or instance.
  # The purpose of this class is to recognize to what scopes model should respond [ based on db columns - we
  # assume that if model has partner_id column, it should be scoped also to partner, if it has company_id, it should
  # be scoped to white label company etc ]. 
  #
  # Usage: 
  #
  # None. This is internal class, used only by this method to generate proper string for class. Should not be used in application.
 
  class ::DefaultScopeBuilder

    def initialize(klass, options = {})
      @klass = klass
      @options = options
    end

    def build_default_scope
      methods = []
      methods << "scope = self.scoped"
      methods << "return scope if PlatformContext.current.nil?"
      if @options[:allow_nil]
        methods << "return scope.where(\"#{@klass.table_name}.instance_id = ? OR #{@klass.table_name}.instance_id is null\", PlatformContext.current.instance.id) if PlatformContext.scoped_to_instance?"
      else
        methods << "return scope.where(:\"#{@klass.table_name}.instance_id\" => PlatformContext.current.instance.id) if PlatformContext.scoped_to_instance?"
      end
      if (@klass.column_names.include?('company_id') || Company == @klass)
        methods << "if PlatformContext.current.white_label_company.present?"
        if Company == @klass
          methods << "scope.where(:\"#{@klass.table_name}.id\" => PlatformContext.current.white_label_company.id)"
        else
          methods << "scope.where(:\"#{@klass.table_name}.company_id\" => PlatformContext.current.white_label_company.id)"
        end
        methods << "else"
      end
      methods << "scope = scope.where(:\"#{@klass.table_name}.listings_public\" => true )" if @klass.column_names.include?('listings_public')
      if @klass.column_names.include?('partner_id')
        methods << "if PlatformContext.current.partner.present? && PlatformContext.current.partner.search_scope_option.all_associated_listings?"
        methods << "scope.where(:\"#{@klass.table_name}.partner_id\" => PlatformContext.current.partner.id)" 
        methods << "else"
      end
      if @options[:allow_nil]
        methods << "scope.where(\"#{@klass.table_name}.instance_id = ? OR #{@klass.table_name}.instance_id is null\", PlatformContext.current.instance.id)"
      else
        methods << "scope.where(:\"#{@klass.table_name}.instance_id\" => PlatformContext.current.instance.id)"
      end
      if @klass.column_names.include?('partner_id')
        methods << "end"
      end
      if (@klass.column_names.include?('company_id') || Company == @klass)
        methods << "end"
      end
      methods
    end

  end

end
