class User < Omnisocial::User
  # Make any customisations here
  has_many :workplaces, :foreign_key => "creator_id"
  has_many :bookings
end