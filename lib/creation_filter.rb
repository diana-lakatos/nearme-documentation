module CreationFilter
  extend ActiveSupport::Concern

  included do
    scope :created_between, -> (start_date, end_date) { where('created_at >= ? AND created_at < ?', start_date, end_date) }
  end
end
