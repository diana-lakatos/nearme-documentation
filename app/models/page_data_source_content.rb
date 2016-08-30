class PageDataSourceContent < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :page
  belongs_to :data_source_content
end
