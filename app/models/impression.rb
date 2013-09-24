class Impression < ActiveRecord::Base
  belongs_to :impressionable, :polymorphic => true

  attr_accessible :impressionable_id, :impressionable_type, :ip_address
end
