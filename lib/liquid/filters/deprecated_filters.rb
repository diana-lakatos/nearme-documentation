# frozen_string_literal: true
module Liquid
  module Filters
    module DeprecatedFilters
      # Sets the @no_footer variable to true to affect further rendering (i.e. the footer
      #   will not be rendered)
      # @return [nil]
      def no_footer!
        @no_footer = true
      end

      # @return [Hash] returns data
      # @param query_string [String] graphql query
      # @param params [Hash, nil] variables used in query
      # @param current_user [User]
      def query(query_string, params = {}, current_user = nil)
        ::Graph.execute_query(
          query_string,
          variables: params,
          context: {
            current_user: current_user
          }
        )
      end

      # @return [String, nil] path to the first searchable listing for the location given as
      #   parameter; nil if no such listing can be found
      # @param location [LocationDrop] location object whose first listing path is extracted
      # @todo Investigate/remove unused _transactable_type parameter?
      def location_path(_transactable_type, location)
        return '' if location.blank?
        location.listings.searchable.first.try(:decorate).try(:show_path)
      end

      # @return [Hash{String => String}] hash of the form !{ 'price' => '$20', 'period' => 'day' } price is a formatted lowest price
      #   for the object given as parameter (without cents, with currency included); does not include additional charges and
      #   service guest fee; for the period, the translation key 'search.per_unit_price' is used with the 'unit' being "search.#{pricing.unit}"
      #   pricing.unit is the actual unit of the pricing (e.g. day, hour, etc.)
      # @param object [LocationDrop, TransactableDrop] object whose price we want to display
      # @param lgpricing_filters [Array<String>] array of pricing type filters (e.g. ["1_day", "1_hour"])
      #   usually passed from the search page
      def lowest_price_without_cents_with_currency(object, lgpricing_filters = [])
        get_lowest_price_with_options(object, lgpricing_filters)
      end

      # @return [Hash{String => String}] hash of the form !{ 'price' => '$20', 'period' => 'day' } price is a formatted lowest full price
      #   for the object given as parameter (without cents, with currency included); includes additional charges and service guest fee;
      #   for the period, the translation key 'search.per_unit_price' is used with the 'unit' being "search.#{pricing.unit}"
      #   pricing.unit is the actual unit of the pricing (e.g. day, hour, etc.)
      # @param object [LocationDrop, TransactableDrop] object whose price we want to display
      # @param lgpricing_filters [Array<String>] array of pricing type filters (e.g. ["1_day", "1_hour"])
      #   usually passed from the search page
      def lowest_full_price_without_cents_with_currency(object, lgpricing_filters = [])
        get_lowest_price_with_options(object, lgpricing_filters, full_price: true)
      end

      # @return [Hash{String => String}] hash of the form !{ 'price' => '$20', 'period' => 'day' } price is a formatted lowest full price
      #   for the object given as parameter (with cents, with currency included); includes additional charges and service guest fee;
      #   for the period, the translation key 'search.per_unit_price' is used with the 'unit' being "search.#{pricing.unit}"
      #   pricing.unit is the actual unit of the pricing (e.g. day, hour, etc.)
      # @param object [LocationDrop, TransactableDrop] object whose price we want to display
      # @param lgpricing_filters [Array<String>] array of pricing type filters (e.g. ["1_day", "1_hour"])
      #   usually passed from the search page
      def lowest_full_price_with_cents_with_currency(object, lgpricing_filters = [])
        get_lowest_price_with_options(object, lgpricing_filters, full_price: true, with_cents: true)
      end

      def get_lowest_price_with_options(object, lgpricing_filters, options = {})
        lgpricing_filters ||= []

        pricing = if options[:full_price]
                    object.lowest_full_price(lgpricing_filters)
                  else
                    object.lowest_price(lgpricing_filters)
                  end

        if pricing.nil? || pricing.is_free_booking?
          { 'free' => true }
        else
          if options[:with_cents]
            { 'price' => price_with_cents_with_currency(pricing.price) }
          else
            { 'price' => price_without_cents_with_currency(pricing.price) }
          end.merge('period' => pricing.decorate.units_translation('search.per_unit_price', 'search'))
        end
      end

      # @return [Hash{String => String}] hash of the form !{ 'price' => '$20', 'period' => 'day' } price is a formatted lowest price
      #   for the object given as parameter (with cents, with currency included); does not include additional charges and service guest fee;
      #   for the period, the translation key 'search.per_unit_price' is used with the 'unit' being "search.#{pricing.unit}"
      #   pricing.unit is the actual unit of the pricing (e.g. day, hour, etc.)
      # @param object [LocationDrop, TransactableDrop] object whose price we want to display
      # @param lgpricing_filters [Array<String>] array of pricing type filters (e.g. ["1_day", "1_hour"])
      #   usually passed from the search page
      def lowest_price_with_cents_with_currency(object, lgpricing_filters = [])
        pricing = object.lowest_price(lgpricing_filters)
        if pricing
          { 'price' => price_with_cents_with_currency(pricing.price), 'period' => pricing.decorate.units_translation('search.per_unit_price', 'search') }
        else
          {}
        end
      end

      # @return [Array<String>] array of connection information strings for a user and a listing; for each of the user's friends
      #   (followed users) strings will be generated like so:
      #   If the friend visited the listing, the string 'User.name worked here' will be added.
      #   If the friend is the host of the listing, the string 'User.name is the host' will be added.
      #   If the friend knows the host of the listing the string 'User.name knows the host' will be added.
      #   If a mutual friend (followed user [2] by a user this user follows [1]) visited the listing then the string
      #     'User[1].name knows User[2].name who worked here'
      # @param listing [TransactableDrop] Transactable object used in the generation of the resulting array
      # @param current_user [UserDrop] User object used in the generation of the resulting array
      def connections_for(listing, current_user)
        return [] if current_user.nil? || current_user.friends.count.zero?

        friends = current_user.friends.visited_listing(listing).collect do |user|
          "#{user.name} worked here"
        end

        hosts = current_user.friends.hosts_of_listing(listing).collect do |user|
          "#{user.name} is the host"
        end

        host_friends = current_user.friends_know_host_of(listing).collect do |user|
          "#{user.name} knows the host"
        end

        mutual_visitors = current_user.mutual_friends.visited_listing(listing).collect do |user|
          next unless user.mutual_friendship_source
          "#{user.mutual_friendship_source.name} knows #{user.name} who worked here"
        end

        [friends, hosts, host_friends, mutual_visitors].flatten
      end

      # @return [String] string to be used as a tooltip displaying the connections {Liquid::LiquidFilters#connections_for}
      #   for a listing and a user; if there are more than 5 connections the translation
      #   'search.list.additional_social_connections' (with the parameter count) is added to the tooltip
      # @param connections [Array<String>] array of connections to be displayed in the tooltip
      # @param size [Integer] the first 'size' connections will be shown in the tooltip
      def connections_tooltip(connections, size = 5)
        difference = connections.size - size
        connections = connections.first(size)
        connections << t('search.list.additional_social_connections', count: difference) if difference > 0
        connections.join('<br />').html_safe
      end

      # @return [String] url to a placeholder image with the width and height given as parameters
      # @param height [Integer] height of the placeholder image
      # @param width [Integer] width of the placeholder image
      def space_listing_placeholder_path(height, width)
        ActionController::Base.helpers.asset_url(Placeholder.new(height: height.to_i, width: width.to_i).path)
      end

      # @return [String] translated property name; if the property is a basic transactable
      #   attribute the translation key is 'simple_form.labels.transactable.#!{property_name}';
      #   if it's a custom attribute, the translation key is 'transactable_type.#{transactable_type.name}.labels.#!{property_name}'
      # @param property [String] property name to be translated
      # @param target_acting_as_set [TransactableTypeDrop] transactable type that the property belongs to
      def translate_property(property, target_acting_as_set)
        if Transactable::DEFAULT_ATTRIBUTES.include? property
          # These are the hard coded attributes that have their own column on the transactables table
          translate("simple_form.labels.transactable.#{property}")
        else
          # These are the custom attributes added by the MPO
          translate("#{target_acting_as_set.translation_namespace}.labels.#{property}")
        end
      end

      # @return [String] HTML formatted pagination area generated for the input collection with the passed in options
      # @param collection [Array<Object>] array of objects for which we want to generate the pagination area
      # @param options [Hash{String => String}] hash of options for pagination; example:
      #   !{{ listings | pagination_links: param_name: 'services_page', renderer: 'LiquidStyledLinkRenderer' }} will
      #   render the pagination links for listings; services_page will be the name of the page parameters in the browser
      #   and the LiquidStyledLinkRenderer renderer will be used to generate the output HTML
      def pagination_links(collection, options = {})
        opts = {
          controller: @context.registers[:controller],
          renderer: 'LiquidLinkRenderer'
        }.merge(options.symbolize_keys)
        will_paginate collection, opts
      end

      # @return [String] returns the value of the request attribute indicated by the parameter 'method'; e.g.
      #   !{{ 'original_url' | request_parameter }}
      # @param method [String] name of the request attribute to return
      def request_parameter(method)
        @context.registers[:controller].request.send(method.to_sym) if @context.registers[:controller].request.respond_to?(method)
      end

      # @return [String] if the tag given as a parameter is already in the URL parameter for filtering by
      #   tags it will return a link to the tag which will remove it from the filter; otherwise, if the tag
      #   given as a parameter is not already in the URL parameter for filtering by tags, it will return a
      #   link to the tag which will add this tag to the tag filter
      # @param custom_classes [Array] array of custom classes to be added to the class attribute of the
      #   generated link
      def tag_filter_link(tag, custom_classes = [])
        params = @context.registers[:controller].params
        current_filters = params[:tags].try(:split, ',').presence || []

        if current_filters.try(:include?, tag.slug).presence
          filters_without_current = (current_filters - [tag.slug]).join(',')

          href = "?tags=#{filters_without_current}"
          classes = %w(add selected)
        else
          filters = (current_filters + [tag.slug]).uniq.join(',')

          href = "?tags=#{filters}"
          classes = %w(add)
        end

        classes.push(custom_classes).flatten!.uniq! if custom_classes.present?

        link_to(tag.name, href, class: classes.join(' '))
      end

      # @return [String] renders a form with search boxes for the specified transactable types and with the given options
      # @param tt_names [String] Transactable Type names separated by ','
      # @param class_name [String] additional CSS class name to be used for the search form
      # @param inputs [String] what inputs should be displayed: geolocation, fulltext, categories, datepickers. Separated by ','
      def search_box_for(tt_names, class_name = '', inputs = '')
        names = tt_names.split(',').map(&:strip)
        tt = TransactableType.where(name: names) + InstanceProfileType.where(name: names)
        if tt.any?
          ordered = {}
          tt.map { |searchable| ordered[names.index(searchable.name)] = searchable }
          ordered = ordered.sort.to_h
          @context.registers[:action_view].render 'home/search_box_inputs.html',
                                                  transactable_types: ordered.values,
                                                  custom_search_inputs: inputs.split(',').map(&:strip),
                                                  class_name: class_name + ' search-box-liquid-tag',
                                                  transactable_type_picker: ordered.values.many?
        else
          "No Service or Product type with names: #{tt_names}"
        end
      end

      # @return [String] renders a search button in a form for the given transactable type and with the given options
      # @param tt_name [String] Transactable Type name
      # @param class_name [String] additional CSS class name to be used for the search form containing the
      #   search button
      def search_button_for(tt_name, class_name = '')
        if tt = TransactableType.find_by(name: tt_name.strip) || tt = InstanceProfileType.find_by(name: tt_name.strip)
          @context.registers[:action_view].render 'home/search_button_tag.html',
                                                  transactable_type: tt,
                                                  class_name: class_name + ' search-box-liquid-tag'
        else
          "No Service or Product type with name: #{tt_name}"
        end
      end



      # @return [Boolean] whether the user has the given object among his wishlisted items
      # @param user [UserDrop] user object
      # @param object [Object] any object; we look among the user's wishlisted items for this object
      def already_favorite(user, object)
        return false unless user.present?
        user.default_wish_list.items.where(wishlistable_id: object.id, wishlistable_type: object.class_name).exists?
      end

      # @return [Array<ReverseProxyLinkDrop>] array of ReverseProxyLink objects to be used on the url given as a parameter;
      #   they define target destinations for the given url, eg: { current_url | widget_links } or { current_url | widget_links: 'per_page,loc' }
      # @param url [String] url for the ReverseProxyLink objects
      # @param valid_params [String] query params separated by comma used to search proper ReverseProxyLink
      def widget_links(url, valid_params = '')
        return [] unless url.present?
        uri = Addressable::URI.parse(::CGI.unescapeHTML(url.to_str))

        whitelisted_query = Rack::Utils.parse_nested_query(uri.query).slice(*valid_params.split(',')).to_query
        whitelisted_query.prepend('?') if whitelisted_query.present?

        ReverseProxyLink.where(use_on_path: uri.path + whitelisted_query)
      end

      # @return [TransactableCollaboratorDrop] transactable collaborator object for the given transactable and user;
      #   this object ties the collaborating user to the transactable
      # @param user [UserDrop] collaborating User object
      # @param transactable [TransactableDrop] Transactable object
      def find_collaborator(user, transactable)
        return false if user.try(:id).blank?
        transactable.transactable_collaborators.where(user: user.id).first
      end

      # @return [Array<Integer>] array of ids of the TransactableCollaborator objects defining collaborations of the
      #   user given as the user parameter, collaborations on Transactable objects (with the state pending, or in_progress
      #   created by the user given as the current_user parameter
      # @param current_user [UserDrop] user object
      # @param user [UserDrop] user object
      def find_collaborators_for_user_transactables(current_user, user)
        user.source.transactable_collaborators.where(transactable_id: current_user.source.created_listings.with_state([:pending, :in_progress]).pluck(:id))
      end

      # @return [Boolean] whether the given user is an approved transactable collaborator of the Transactable given as the parameter
      # @param user [UserDrop] user object
      # @param transactable [TransactableDrop] transactable object
      def is_approved_collaborator(user, transactable)
        return false if user.try(:id).blank?
        transactable.approved_transactable_collaborators.where(user: user.id).exists?
      end

      # @return [Integer] total number of entries for the paginated collection of items passed in
      # @param will_paginate_collection [WillPaginate::Collection] paginated collection of items
      def total_entries(will_paginate_collection)
        will_paginate_collection.total_entries
      end

      # @return [Array<OrderDrop>] array of orders for transactable, belonging to user, ordered
      #   descending by the creation date
      # @param user [UserDrop] user whose orders we want to show
      # @param transactable [TransactableDrop] orders are for this transactable
      def get_enquirer_draft_orders(user, transactable)
        transactable.line_item_orders.where(user_id: user.id).order('created_at ASC')
      end

      # @return [Array<OrderDrop>] array of order objects containing orders placed by the user given
      #   as the first parameter for the transactable given as the second parameter
      # @param user [UserDrop] transactable object
      # @param transactable [TransactableDrop] transactable object
      def get_enquirer_orders(user, transactable)
        get_enquirer_draft_orders(user, transactable).active
      end

      # @return [Array<OrderDrop>] array of confirmed order objects containing orders placed by the
      # user given as the first parameter for the transactable given as the second parameter
      # @param user [UserDrop] transactable object
      # @param transactable [TransactableDrop] transactable object
      def get_enquirer_confirmed_orders(user, transactable)
        get_enquirer_draft_orders(user, transactable).confirmed
      end

      # @return [Array<OrderDrop>] array of order objects
      # @param user [UserDrop] orders returned are for items belonging to this user's companies
      # @param transactable [TransactableDrop] orders returned are for this transactable
      def get_lister_orders(user, transactable)
        transactable.line_item_orders.where(company: user.companies).active.order('created_at ASC')
      end

      # @return [Array<DataSourceContentDrop>] paginated array of DataSourceContent objects where the external_id
      #   matches the one given as the parameter; the pagination is done using options passed in
      #   as the second parameter
      # @param external_id [Integer] we will search for DataSourceContent object matching this external_id
      # @param options [Hash] options for paginating the results; only per_page will be employed
      #   e.g. 12 | get_data_contents: per_page: 5
      def get_data_contents(external_id, options = {})
        data_source_contents = DataSourceContent.where('external_id like ?', external_id)
        data_source_contents.paginate(per_page: options[:per_page].presence || 10)
      end

      # @return [Boolean] whether the element identified by the given key is visible according to the
      #   rules defined by the hidden UI controls in the admin section of the marketplace
      # @param key [String] key identifying a UI element e.g. 'dashboard/credit_cards'
      def is_visible(key)
        HiddenUiControls.find(key).visible?
      end

      # @return [Integer] the ID of the PaymentGateway for which the credit card payment
      #   method exists
      def get_payment_gateway_id(_str)
        PaymentGateway.with_credit_card.mode_scope.first.try(:id)
      end


      # @return [Array<CkeditorAssetDrop>] seller attachments tied to the given transactable object
      #   and that are visible by the given user
      # @param transactable_drop [TransactableDrop] transactable object
      # @param user_drop [UserDrop] user object
      def attachments_visible_for(transactable_drop, user_drop)
        transactable_drop.source.attachments_visible_for(user_drop.source)
      end

      # @return [Array<CkeditorAssetDrop>] paginated array of Ckeditor::Asset objects matching the given access_level
      #   and the options in the options hash
      # @param access_level [String] can be all, purchasers, enquirers, collaborators
      # @param options [Hash] options hash
      #   * sort - sort by (created_at, name)
      #   * direction - ordering direction (asc, desc)
      #   * query - string to match against the file name or the title of the object
      #   * per_page - number of items per page
      #   * page - the page to display from the paginated array
      def get_ckeditor_assets(access_level, options = {})
        sort_option = %w(created_at name).detect { |valid_key| options['sort'] == valid_key } || 'created_at'
        sort_direction = %w(asc desc).detect { |valid_key| options['direction'] == valid_key } || 'desc'
        Ckeditor::Asset.where(access_level: access_level)
                      .where('data_file_name LIKE ? OR title LIKE ?', "%#{options['query']}%", "%#{options['query']}%")
                      .order("#{sort_option} #{sort_direction}")
                      .paginate(page: options['page'] || 1, per_page: [(options['per_page'] || 10).to_i, 50].min)
      end

      # @return [String] path used for a form for creating a new message in a thread
      # @param displayed_user_message [UserMessageDrop] the parent displayed message
      # @param user_message [UserMessageDrop]
      def user_message_create_path(displayed_user_message, user_message)
        displayed_user_message.user_message.decorate.create_path(user_message.try(:user_message))
      end

      # @return [Boolean] checks if user is following events for activity stream
      # @param user [User] user we are checking against
      # @param object_id [Integer] object id we are checking for
      # @param object_type [String] class name of the object we are checking for - User, Topic, Transactable
      def is_user_following(user, object_id, object_type)
        user.source.activity_feed_subscriptions.where(followed_id: object_id, followed_type: object_type).any?
      end

      # @return [String] information about the unit pricing e.g. 'Every calendar month price'
      # @param transactable_pricing [TransactablePricingDrop] transactable pricing object
      # @param base_key [String] base translation key
      # @param units_namespace [String] namespace for the units e.g. 'reservations'
      def pricing_units_translation(transactable_pricing, base_key, units_namespace)
        transactable_pricing.source.decorate.units_translation(base_key, units_namespace)
      end

      def group_rules_by_day(rules)
        grouped_hash = {}
        rules.each do |rule|
          rule.fetch('days').each do |d|
            grouped_hash[d] ||= Set.new
            grouped_hash[d] << rule
          end
        end
        grouped_hash.each do |k, v|
          grouped_hash[k] = v.sort_by { |r| [r['open_hour'], r['open_minute']] }
        end
        Hash[grouped_hash.sort]
      end
    end
  end
end
