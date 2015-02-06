class Schedule < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :scheduable, polymorphic: true

  def schedule
    @schedule ||= IceCube::Schedule.from_hash(JSON.parse(super || '{}'))
  end

end

