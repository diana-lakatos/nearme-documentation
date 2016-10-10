class DataSource < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :data_sourcable, polymorphic: true
  serialize :settings, Hash

  has_many :data_source_contents, dependent: :destroy

  def latest_item_pub_date
    data_source_contents.maximum('externally_created_at')
  end

  def parse!
    fail NotImplementedError.new('Must implement')
  end
end
