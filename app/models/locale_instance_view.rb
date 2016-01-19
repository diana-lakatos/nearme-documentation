class LocaleInstanceView < ActiveRecord::Base
  scoped_to_platform_context
  auto_set_platform_context

  belongs_to :locale, touch: true
  belongs_to :instance_view, touch: true

end
