# frozen_string_literal: true
SimpleNavigation::Configuration.run do |navigation|
  def dashboard_nav_item(nav, key = nil, path = nil, options = {})
    unless options[:not_hideable]
      return nil if HiddenUiControls.find(key).hidden?
    end

    key_controller = key.split('/').last
    options.reverse_merge!(link_text: t("dashboard.nav.#{key_controller}"), if: true, unless: false, highlights_on: nil)

    nav.item key_controller, options[:link_text], path, unless: -> { options[:unless] }, if: -> { options[:if] }, highlights_on: options[:highlights_on]
  end

  navigation.id_generator = proc { |key| "dashboard-nav-#{key}" }

  navigation.items do |primary|
    dashboard_nav_item primary, 'dashboard/user_messages', dashboard_user_messages_path, highlights_on: /user_messages/, link_text: dashboard_nav_user_messages_label

    primary.item :reviews, t('dashboard.nav.reviews'), nil, if: proc { platform_context.instance.rating_systems.where(active: true).present? } do |sub_nav|
      dashboard_nav_item sub_nav, 'dashboard/reviews_rate', rate_dashboard_reviews_path, highlights_on: /dashboard\/reviews\/rate/
      dashboard_nav_item sub_nav, 'dashboard/reviews_completed', completed_dashboard_reviews_path, highlights_on: /dashboard\/reviews\/completed/
    end
    dashboard_nav_item primary, 'dashboard/wish_list_items', dashboard_wish_list_items_path, link_text: t('wish_lists.name'), if: platform_context.instance.wish_lists_enabled?, highlights_on: /dashboard\/favorites/
    dashboard_nav_item primary, 'dashboard/my_rfq', dashboard_user_requests_for_quotes_path, not_hideable: true, if: platform_context.instance.action_rfq?, highlights_on: /dashboard\/user_requests_for_quotes(\/.+)*/

    if buyable?
      primary.item :products_header, t('dashboard.nav.products_header'), nil do |sub_nav|
        dashboard_nav_item sub_nav, 'dashboard/orders', dashboard_orders_path, highlights_on: /dashboard\/orders(\/.+)*/
        if current_user.registration_completed?
          dashboard_nav_item sub_nav, 'dashboard/orders_received', dashboard_company_orders_received_index_path, highlights_on: /dashboard\/company\/orders_received(\/.+)*/
          dashboard_nav_item sub_nav, 'dashboard/products', dashboard_company_product_type_products_path(Spree::ProductType.first), highlights_on: /dashboard\/company\/product_type(\/.+)*/
        end
      end
    end

    if projectable?
      primary.item :projects_header, t('dashboard.nav.projects_header'), nil do |_sub_nav|
        dashboard_nav_item primary, 'dashboard/projects', dashboard_project_type_projects_path(ProjectType.first)
      end
    end

    if bookable?
      primary.item :services_header, "#{t('dashboard.nav.services_header')} #{current_user_open_all_reservations_count_formatted}", nil do |sub_nav|
        if !current_instance.split_registration || current_user.buyer_profile.present?
          dashboard_nav_item sub_nav, 'dashboard/user_reservations', dashboard_user_reservations_path, highlights_on: /\/user_reservations\/*/, link_text: dashboard_nav_user_reservations_label
        end

        if subscribable?
          dashboard_nav_item sub_nav, 'dashboard/user_recurring_bookings', active_dashboard_user_recurring_bookings_path, highlights_on: /\/user_recurring_bookings\/*/
        end

        if current_user.registration_completed?
          dashboard_nav_item sub_nav, 'dashboard/host_reservations', dashboard_company_host_reservations_path, highlights_on: /\/(host_reservations)\/*/, link_text: dashboard_nav_host_reservations_label
          if subscribable?
            dashboard_nav_item sub_nav, 'dashboard/host_recurring_bookings', dashboard_company_host_recurring_bookings_path, highlights_on: /\/host_recurring_bookings\/*/
          end

          dashboard_nav_item sub_nav, 'dashboard/transactables', dashboard_company_transactable_type_transactables_path(TransactableType.first), highlights_on: /dashboard\/company\/(service_types|transactable_types)/
        end
      end
    end

    if biddable?
      primary.item :offers_header, t('dashboard.nav.offers_header'), nil do |sub_nav|
        dashboard_nav_item sub_nav, 'dashboard/user_bids', dashboard_user_bids_path, highlights_on: /\/user_bids\/*/

        if current_user.registration_completed?
          dashboard_nav_item sub_nav, 'dashboard/user_auctions', dashboard_company_user_auctions_path, highlights_on: /\/(user_auctions)\/*/
          dashboard_nav_item sub_nav, 'dashboard/offers', dashboard_company_offer_type_offers_path(OfferType.first), highlights_on: /dashboard\/company\/offer_types/
        end
      end
    end

    if current_user.registration_completed? && @company
      primary.item :admin, t('dashboard.nav.admin'), nil do |sub_nav|
        dashboard_nav_item sub_nav, 'dashboard/companies', edit_dashboard_company_path(@company), highlights_on: /dashboard\/companies\/[0-9]+(\/edit)?/
        dashboard_nav_item sub_nav, 'dashboard/payouts', edit_dashboard_company_payouts_path, highlights_on: /dashboard\/company\/payouts/
        dashboard_nav_item sub_nav, 'dashboard/transfers', dashboard_company_transfers_path, highlights_on: /dashboard\/company\/transfers/
        dashboard_nav_item sub_nav, 'dashboard/analytics', dashboard_company_analytics_path, highlights_on: /dashboard\/company\/analytics/
        dashboard_nav_item sub_nav, 'dashboard/users', dashboard_company_users_path, highlights_on: /dashboard\/company\/users/
        dashboard_nav_item sub_nav, 'dashboard/waiver_agreement_templates', dashboard_company_waiver_agreement_templates_path, highlights_on: /dashboard\/company\/waiver_agreement_templates/
        dashboard_nav_item sub_nav, 'dashboard/white_labels', edit_dashboard_company_white_label_path(current_user.companies.first), highlights_on: /dashboard\/company\/white_labels/
        dashboard_nav_item sub_nav, 'dashboard/tickets', dashboard_company_support_tickets_path, if: platform_context.instance.action_rfq?, highlights_on: /dashboard\/company\/support\/tickets(\/[0-9]+)?/
        dashboard_nav_item sub_nav, 'dashboard/payment_documents/sent_to_me', sent_to_me_dashboard_company_payment_documents_path, if: platform_context.instance.documents_upload_enabled?, highlights_on: /dashboard\/company\/payment_documents/
      end
    end

    if platform_context.instance.blogging_enabled?(current_user)
      primary.item :blog, t('dashboard.nav.blog'), nil do |sub_nav|
        dashboard_nav_item sub_nav, 'dashboard/blog', dashboard_blog_path, link_text: t('dashboard.nav.blog_posts'), highlights_on: proc { (params[:controller].include?('user_blog') && params[:action] == 'show') || params[:controller].include?('blog_posts') }
        dashboard_nav_item sub_nav, 'dashboard/blog', edit_dashboard_blog_path, link_text: t('dashboard.nav.blog_settings'), highlights_on: proc { params[:controller].include?('user_blog') && (params[:action] == 'edit' || params[:action] == 'update') && !params[:controller].include?('blog_posts') }
      end
    end

    primary.item :account, t('dashboard.nav.account'), nil do |sub_nav|
      dashboard_nav_item sub_nav, 'registrations/edit', dashboard_profile_path, link_text: t('dashboard.nav.edit'), highlights_on: /(users\/edit|dashboard\/seller\/edit|dashboard\/buyer\/edit|dashboard\/edit_profile)/
      if (payment_gateway = PaymentGateway.with_credit_card.mode_scope.first).present? && current_user.has_active_credit_cards?
        dashboard_nav_item sub_nav, 'dashboard/credit_cards', dashboard_payment_gateway_credit_cards_path(payment_gateway), highlights_on: /dashboard\/payment_gateways\/[0-9]+\/credit_card/
      end
      dashboard_nav_item sub_nav, 'dashboard/notification_preferences', edit_dashboard_notification_preferences_path, link_text: t('dashboard.nav.notification_preferences'), highlights_on: /dashboard\/notification_preferences/
      dashboard_nav_item sub_nav, 'registrations/social_accounts', social_accounts_path, link_text: t('dashboard.nav.social_accounts'), highlights_on: /dashboard\/social_accounts/
      if HiddenUiControls.find('dashboard/saved_searches').visible?
        dashboard_nav_item sub_nav, 'dashboard/saved_searches', dashboard_saved_searches_path, link_text: t('dashboard.nav.saved_searches'), highlights_on: /dashboard\/saved_searches/
      end
    end
  end
end
