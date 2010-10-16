class User < Omnisocial::User
  # Make any customisations here
  has_many :workplaces, :foreign_key => "creator_id"
end