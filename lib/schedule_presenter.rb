class SchedulePresenter
  include ActionView::Helpers::TextHelper

  attr_accessor :datetime

  def initialize(datetime)
    @datetime = datetime
  end

  def selected_date_summary
    if @datetime.present?
      I18n.l(@datetime, format: :long)
    end
  end


end

