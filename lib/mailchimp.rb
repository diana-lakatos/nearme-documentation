class Mailchimp

  def initialize(api_wrapper, list_id)
    @list_id = list_id
    @api_wrapper = api_wrapper
    @exporter_wrapper = api_wrapper.get_exporter
  end

  def get_users_from_mailchimp
    @existing_users = {}
    header_received = false
    @exporter_wrapper.list({:id => @list_id}).each do |text_response|
      if header_received
        @json_response = JSON.parse(text_response)
        # we want hash like {email1 => { :prop1 => val, ... }, :email2 => { ... } }
        @existing_users[get_value_for("Email Address")] = {
          'no_price' => get_value_for('No pricing').blank? ? '1' : get_value_for('No pricing'),
          'no_photo' => get_value_for('No photo'),
          'verified' => get_value_for('Verified').blank? ? '0' : get_value_for('Verified'),
          'has_listing' => !get_value_for('Edit listing url').empty?,
        }
      else
        @header = Hash[(JSON.parse(text_response).each_with_index.map { |label, index| [label,index]  })]
        header_received = true
      end
    end
  end

  def get_value_for(field_label)
    if @header.key?(field_label)
      @json_response[@header[field_label]]
    else
      puts "Warning! Unknown field label: #{field_label}"
    end
  end

  def export_users
    get_users_from_mailchimp
    final_result = {}

    User.needs_mailchimp_update.find_in_batches(:batch_size => 200) do |users|
      final_result.merge!( 
                          @api_wrapper.list_batch_subscribe(
                            :id => @list_id, 
                            :batch => (users.map { |u| get_merged_vars(u) }),
                            :email_type => "html", 
                            :double_optin => false, 
                            :update_existing => true, 
                            :replace_interests => false, 
                            :send_welcome => false
      )
                         ) {|k, old_v, new_v| old_v + new_v}
                         users.each { |u| u.mailchimp_synchronized! }
    end
    final_result
  end

  def get_merged_vars(user)
    default_hash = {
      :EMAIL => user.email,
      :FNAME => user.first_name,
      :LNAME => user.last_name,
      :NOPHOTOS => (user.photos.count.zero? ? 1 : 0), # note double negation here
      :DASHURL => Rails.application.routes.url_helpers.manage_locations_url,
      :VERIFYURL => Rails.application.routes.url_helpers.verify_user_url(user.id, user.email_verification_token),
      :MODVERIFY => is_verified_after_last_email?(user),
      :DELLIST => deleted_listing_after_last_email?(user)
    }
    if user.listings.count > 0
      default_hash.merge!({
        :LISTURL => Rails.application.routes.url_helpers.manage_location_listing_url(user.listings.first.location, user.listings.first),
        :SPACEURL => Rails.application.routes.url_helpers.location_url(user.listings.first.location),
        :NOPRICE => (user.has_listing_without_price? ? 1 : 0), # note double negation here
        :SPACENAME => user.locations.first.name,
        :SHAREURL => Rails.application.routes.url_helpers.manage_guests_dashboard_url,
        :MODPRICE => was_price_uploaded_since_last_email?(user),
        :MODPHOTO => was_photo_uploaded_since_last_email?(user)
      })
    end
    default_hash
  end

  def was_price_uploaded_since_last_email?(user)
    if @existing_users.key?(user.email)
      ((!user.has_listing_without_price?) && (@existing_users[user.email]['no_price']=='1')) ? 1 : 0
    else
      ''
    end
  end

  def was_photo_uploaded_since_last_email?(user)
    if @existing_users.key?(user.email)
      ((user.photos.count > 0) && (@existing_users[user.email]['no_photo']=='1')) ? 1 : 0
    else
      ''
    end
  end

  def is_verified_after_last_email?(user)
    if @existing_users.key?(user.email)
      (user.verified && (@existing_users[user.email]['verified']=='0')) ? 1 : 0
    else
      ''
    end
  end

  def deleted_listing_after_last_email?(user)
    if @existing_users.key?(user.email)
      (user.listings.count.zero? && (@existing_users[user.email]['has_listing'])) ? 1 : 0
    else
      ''
    end
  end

end
