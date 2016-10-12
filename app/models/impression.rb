class Impression < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  belongs_to :impressionable, polymorphic: true

  # attr_accessible :impressionable_id, :impressionable_type, :ip_address
end
