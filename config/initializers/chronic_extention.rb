# This extention enables Chronic to work in block time zone
# Time.use_zone('Pacific Time (US & Canada)') do
#  Chronic.parse("Sunday")
# end
# See comment for more details: https://github.com/mojombo/chronic/issues/182#issuecomment-227152798

module Chronic
  def self.time_class
    ::Time.zone
  end
end
