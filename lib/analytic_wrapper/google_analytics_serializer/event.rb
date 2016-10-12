# Class to extract params to track Event in google analytics

# see https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide
class AnalyticWrapper::GoogleAnalyticsSerializer::Event
  def initialize(category, action, additional_params = {})
    @category = category
    @action = action
    @additional_params = additional_params
    # tmp hack before figuring our custom variables
    if @additional_params[:search_query].present?
      @label = @additional_params[:search_query]
      @value = @additional_params[:result_count]
    end
  end

  def serialize
    (@label.present? ? { el: @label } : {}).merge(
      @value.present? ? { ev: @value } : {}).merge(t: 'event',
                                                   ec: @category,
                                                   ea: @action)
  end
end
