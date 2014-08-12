class SearchNotificationsController < ApplicationController
  def create
    @search_notification = SearchNotification.new(search_notification_params)
    @search_notification.user = current_user if current_user
    if @search_notification.save
      event_tracker.subscribed_for_search_notification(@search_notification, query: @search_notification.query,
                                                       anonymous: @search_notification.user.present?)
      flash[:notice] = t('flash_messages.search_notifications.you_will_be_notified', bookable_noun: platform_context.decorate.bookable_noun)
    else
      flash[:error] = t('flash_messages.search_notifications.you_will_not_be_notified', email: @search_notification.email, errors: @search_notification.errors.full_messages.to_sentence)
    end
    redirect_to :back
  end

  private

  def search_notification_params
    params.require(:search_notification).permit(secured_params.search_notification)
  end

end
