class ProfileUpdateService
  def initialize(user, attributes = {})
    @user = user
    @attributes = attributes
  end

  def update
    white_listed_attributes = extract_whitelist_attributes(@attributes)
    @user.update_attributes(white_listed_attributes['user'])
    @user.metadata['webhook_attributes'] = @attributes
    @user.save(validate: false)
    @user.default_profile.properties = white_listed_attributes['default_profile_attributes'].presence || {}
    @user.default_profile.save(validate: false)
    address = @user.current_address || @user.build_current_address
    address.attributes = white_listed_attributes['current_address_attributes']
    address.save(validation: false) unless address.address.blank?
    @user.touch
  end

  private

  def extract_whitelist_attributes(attributes)
    attributes.keys.inject({}) do |attrs, key|
      attrs['user'] ||= {}
      attrs['default_profile_attributes'] ||= {}
      attrs['current_address_attributes'] ||= {}
      if user_attributes.keys.include?(key)
        attrs['user'][user_attributes[key]] = attributes[key] unless key == 'email' && attributes[key].present?
      end
      if custom_attributes.keys.include?(key)
        attrs['default_profile_attributes'][custom_attributes[key]] = attributes[key]
      end
      if current_address_attributes.keys.include?(key)
        if key == 'address_1'
          attrs['current_address_attributes']['address'] = current_address_attributes.keys.map { |v| attributes[v] }.reject(&:blank?).join(', ')
        else
          attrs['current_address_attributes'][current_address_attributes[key]] = attributes[key]
        end
      end
      if key == 'is_active'
        attrs['user']['banned_at'] = Time.zone.now unless ActiveRecord::Type::Boolean.new.type_cast_from_user(attributes[:is_active])
      end
      if key == 'is_do_not_contact'
        attrs['user']['accept_emails'] = !ActiveRecord::Type::Boolean.new.type_cast_from_user(attributes[:is_do_not_contact])
      end
      if key == 'language'
        language_match = attributes[:language].to_s.match(%r{(?<language>[a-z]{2})[-_].+$}i)
        if language_match
          attrs['user']['language'] = language_match['language'].downcase
        else
          attrs['user']['language'] = PlatformContext.current.instance.primary_locale
        end
      end
      attrs
    end
  end

  def user_attributes
    {
      last_name: :last_name,
      first_name: :first_name,
      email: :email,
      phone: :mobile_number,
      country: :country_name,
      company: :company_name,
      profile_image: :remote_avatar_url
    }.with_indifferent_access
  end

  def custom_attributes
    {
      belt: :role,
      bio: :short_bio,
      is_internal: :is_intel
    }.with_indifferent_access
  end

  def current_address_attributes
    {
      address_1: :address,
      address_2: :address2,
      city: :city,
      state: :state,
      zip: :postcode,
      country: :country
    }.with_indifferent_access
  end
end
