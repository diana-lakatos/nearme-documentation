class Communication < ActiveRecord::Base
  belongs_to :user

  def to_liquid
    @communication_drop ||= CommunicationDrop.new(self)
  end
end
