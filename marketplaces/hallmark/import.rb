instance = Instance.find(5011)
instance.set_context!
path = Rails.root.join('marketplaces', 'hallmark', 'hallmark-community-users.csv')

NAME = 0
EMAIL = 1
EXTERNAL_ID = 2
ROLE = 3
CSV.foreach(path) do |array|
  unless array[NAME] == 'Name'
    email = array[EMAIL].downcase.strip
    puts "importing: #{email}"
    u = User.where('email ilike ?', email).first_or_initialize
    u.email = email
    u.password = SecureRandom.hex(12)
    u.external_id = array[EXTERNAL_ID]
    u.expires_at = Time.zone.now + 6.months
    u.get_default_profile
    u.name = array[NAME]
    u.default_profile.properties[:role] = array[ROLE].strip
    u.save!
  end
end
