class InstanceCreator < ActiveRecord::Base
  belongs_to :instance
  validates :email, email: true, uniqueness: { case_sensitive: false }
end
