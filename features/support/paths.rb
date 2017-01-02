# frozen_string_literal: true
module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^the home\s?page$/
      '/'

    when /the twitter auth page/
      'auth/twitter'

    when /the account settings page/
      edit_user_registration_path

    when /the settings page/
      edit_dashboard_company_path(model!('the user').companies.first)

    when /the payouts page/
      edit_dashboard_company_payouts_path

    when /the white label settings page/
      edit_dashboard_company_white_label_path(model!('the user').companies.first)

    when /the transactable's page/
      listing = model!('the transactable')
      listing.decorate.show_path

    when /the transactables page/
      listings_path

    when /the guests/
      dashboard_company_orders_received_index_path

    when /the dashboard page/
      dashboard_company_orders_received_index_path

    when /manage guests/
      dashboard_company_orders_received_index_path

    when /confirmed reservations/
      dashboard_company_orders_received_index_path(state: 'confirmed')

    when /the space list page/
      transactable_type_list_path(TransactableType.last)

    when /the bookings/
      dashboard_orders_path

    when /the manage listing page/
      listing = model!('the transactable')
      edit_dashboard_company_transactable_type_transactable_path(listing.transactable_type, listing)

    when /the admin instances page/
      global_admin_instances_path

    when /the instance settings page/
      instance_admin_settings_configuration_path

    when /instance documents upload page/
      instance_admin_settings_documents_upload_path

    when /instance admin sign in page/
      instance_admin_login_path

    when /admin graph queries/
      admin_advanced_graph_queries_path

    when /^(my|my archived|my unconfirmed|unconfirmed|confirmed|overdue|archived) subscriptions page$/
      case Regexp.last_match(1)
      when 'my'
        dashboard_orders_path(state: 'confirmed')
      when 'my unconfirmed'
        dashboard_orders_path(state: 'unconfirmed')
      when 'my archived'
        dashboard_orders_path(state: 'archived')
      when 'unconfirmed'
        dashboard_company_orders_received_index_path(state: 'unconfirmed')
      when 'confirmed'
        dashboard_company_orders_received_index_path(state: 'confirmed')
      when 'overdue'
        dashboard_company_orders_received_index_path(state: 'overdue')
      when 'archived'
        dashboard_company_orders_received_index_path(state: 'archived')
      end

    when /^#{capture_model}(?:'s)? page which belong to deleted location$/ # eg. deleted listing page
      obj = model(Regexp.last_match(1))
      deleted = obj.location.destroy
      raise "Destroy failed for #{Regexp.last_match(1)}" unless deleted
      send("#{obj.class.name.downcase}_path", obj)

    when /^deleted #{capture_model} page$/ # eg. deleted listing page
      obj = model(Regexp.last_match(1))
      deleted = obj.destroy
      raise "Destroy failed for #{Regexp.last_match(1)}" unless deleted
      send("#{obj.class.name.downcase}_path", obj)

    when /^#{capture_model}(?:'s)? page$/                           # eg. the forum's page
      path_to_pickle Regexp.last_match(1)

    when /^#{capture_model}(?:'s)? #{capture_model}(?:'s)? page$/   # eg. the forum's post's page
      path_to_pickle Regexp.last_match(1), Regexp.last_match(2)

    when /^#{capture_model}(?:'s)? #{capture_model}(?:'s)? #{capture_model}(?:'s)? page$/ # eg. we're going three levels
      path_to_pickle Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3)

    when /^#{capture_model}(?:'s)? #{capture_model}'s (.+?) page$/ # eg. the forum's post's comments page
      path_to_pickle Regexp.last_match(1), Regexp.last_match(2), extra: Regexp.last_match(3) #  or the forum's post's edit page

    when /^#{capture_model}(?:'s)? (.+?) page$/ # eg. the forum's posts page
      if Regexp.last_match(2) == 'edit'
        path_to_pickle Regexp.last_match(1), action: Regexp.last_match(2) #  or the forum's edit page
      elsif Regexp.last_match(2) == 'new reservation'
        new_listing_reservation_path(created_model(Regexp.last_match(1)))
      else
        path_to_pickle Regexp.last_match(1), extra: Regexp.last_match(2) #  or the forum's edit page
      end
    when /^the (.+?) page$/ # translate to named route
      send "#{Regexp.last_match(1).downcase.tr(' ', '_')}_path"
      # Add more mappings here.
      # Here is an example that pulls values out of the Regexp:
      #
      #   when /^(.*)'s profile page$/i
      #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = Regexp.last_match(1).split(/\s+/)
        send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" \
              "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
