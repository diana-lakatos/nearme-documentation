class Ckeditor::Asset < ActiveRecord::Base
  include Ckeditor::Orm::ActiveRecord::AssetBase
  auto_set_platform_context
  scoped_to_platform_context

  delegate :url, :current_path, :content_type, :to => :data
  validates_presence_of :data

  belongs_to :instance
end
