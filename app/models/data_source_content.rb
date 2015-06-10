class DataSourceContent < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :data_source

  delegate :fields, to: :data_source

  def to_liquid
    DataSourceContentDrop.new(self)
  end
end

