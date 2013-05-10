class Mailchimp

  def initialize(api_wrapper, list_id)
    @list_id = list_id
    @api_wrapper = api_wrapper
  end

  def export_users
    result = { :new => 0, :updated => 0 }
    User.needs_mailchimp_update.find_each do |user|
      user.mailchimp_exported? ? (result[:updated] += 1) : (result[:new] += 1)
      export_user(user)
      user.mailchimp_synchronized!
    end
    result
  end

  def export_user(user)
    @api_wrapper.list_subscribe({
      :id => @list_id, 
      :email_address => user.email, 
      :merge_vars => get_merged_vars(user), 
      :email_type => "html", 
      :double_optin => false, 
      :update_existing => user.mailchimp_exported?, 
      :replace_interests => false, 
      :send_welcome => false})
  end

  def get_merged_vars(user)
    default_hash = {
      :FNAME => user.first_name,
      :LNAME => user.last_name,
      :NOPHOTOS => (user.photos.count.zero? ? 1 : 0), # note double negation here
      :DASHURL => Rails.application.routes.url_helpers.manage_locations_url,
      :VERIFYURL => Rails.application.routes.url_helpers.verify_user_url(user.id, user.email_verification_token)
    }
    if user.listings.count > 0
      default_hash.merge!({
        :LISTURL => Rails.application.routes.url_helpers.manage_location_listing_url(user.listings.first.location, user.listings.first),
        :SPACEURL => Rails.application.routes.url_helpers.location_url(user.listings.first.location),
        :NOPRICE => (user.has_listing_without_price? ? 1 : 0), # note double negation here
        :SPACENAME => user.locations.first.name,
        :SHAREURL => Rails.application.routes.url_helpers.manage_guests_dashboard_url
      })
    end
    default_hash
  end

end
