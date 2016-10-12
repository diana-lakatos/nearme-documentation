class SchedulePresenter
  include ActionView::Helpers::TextHelper

  attr_accessor :datetime

  def initialize(datetime)
    @datetime = datetime
  end

  def selected_date_summary
    I18n.l(@datetime, format: :long) if @datetime.present?
  end
end
