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
      edit_manage_company_path(model!('the user'))

    when /the white label settings page/
      edit_manage_white_label_path(model!('the user'))

    when /the listings page/
      listings_path

    when /the dashboard/
      dashboard_path

    when /the bookings/
      bookings_dashboard_path

    when /the guests/
      manage_guests_dashboard_path

    when /the manage locations page/
      manage_locations_path

    when /the manage listing page/
      listing = model!('the listing')
      edit_manage_location_listing_path(listing.location, listing)

    when /the admin instances page/
      admin_instances_path

    when /the not configured domain page/
      'http://test.example.info'
 
    when /^#{capture_model} page which belong to deleted location$/   # eg. deleted listing page
      obj = model($1)
      deleted = obj.location.destroy
      raise "Destroy failed for #{$1}" unless deleted
      send("#{obj.class.name.downcase}_path", obj)

    when /^deleted #{capture_model} page$/   # eg. deleted listing page
      obj = model($1)
      deleted = obj.destroy
      raise "Destroy failed for #{$1}" unless deleted
      send("#{obj.class.name.downcase}_path", obj)

    when /^#{capture_model}(?:'s)? page$/                           # eg. the forum's page
      path_to_pickle $1

    when /^#{capture_model}(?:'s)? #{capture_model}(?:'s)? page$/   # eg. the forum's post's page
      path_to_pickle $1, $2

    when /^#{capture_model}(?:'s)? #{capture_model}(?:'s)? #{capture_model}(?:'s)? page$/   # eg. we're going three levels
      path_to_pickle $1, $2, $3

    when /^#{capture_model}(?:'s)? #{capture_model}'s (.+?) page$/  # eg. the forum's post's comments page
      path_to_pickle $1, $2, :extra => $3                           #  or the forum's post's edit page

    when /^#{capture_model}(?:'s)? (.+?) page$/                     # eg. the forum's posts page
      if($2 == 'edit')
        path_to_pickle $1, :action => $2                               #  or the forum's edit page
      elsif($2 == 'new reservation')
        new_listing_reservation_path(created_model($1))
      else
        path_to_pickle $1, :extra => $2                               #  or the forum's edit page
      end
    when /^the (.+?) page$/                                         # translate to named route
      send "#{$1.downcase.gsub(' ','_')}_path"
      # Add more mappings here.
      # Here is an example that pulls values out of the Regexp:
      #
      #   when /^(.*)'s profile page$/i
      #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /^the (.*) page$/
          path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
