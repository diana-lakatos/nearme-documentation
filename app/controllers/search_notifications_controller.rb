class SearchNotificationsController < ApplicationController
  def create
    @search_notification = SearchNotification.new(params[:search_notification])
    @search_notification.user = current_user if current_user
    if @search_notification.save
      event_tracker.subscribed_for_search_notification(@search_notification, query: @search_notification.query,
                                                       anonymous: @search_notification.user.present?)
      flash[:notice] = t('search_notifications.you_will_be_notified')
      render json: { status: 'success' }
    else
      render partial: 'form', locals: { search_notification: @search_notification }
    end
  end
end
