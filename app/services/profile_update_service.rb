class ProfileUpdateService
  def initialize(user, attributes = {})
    @user = user
    @attributes = attributes
  end

  def update
    @user.update_attributes(extract_whitelist_attributes(@attributes))
    @user.save!
  end

  private

  def extract_whitelist_attributes(attributes)
    Hash[ whitelist_mapping.map { |k, v| [k, attributes[v]] } ]
  end

  def whitelist_mapping
    {
      last_name: :last_name,
      first_name: :first_name,
      email: :email
    }
  end

end
