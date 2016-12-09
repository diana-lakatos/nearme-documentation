class ExternalApiRequest < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :context, polymorphic: true
end
