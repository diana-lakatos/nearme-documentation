class DataSourceContent < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :data_source

  has_many :page_data_source_content, dependent: :destroy

  def to_liquid
    @data_source_content_drop ||= DataSourceContentDrop.new(self)
  end

  def fields
    data_source.fields
  end
end

