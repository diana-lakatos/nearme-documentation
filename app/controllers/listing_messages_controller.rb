class ListingMessagesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_listing_messages_decorator

  def index
    @threaded_listing_messages = @listing_messages_decorator.inbox.fetch
  end

  def archived
    @threaded_listing_messages = @listing_messages_decorator.archived.fetch
    render :index
  end

  private
  def set_listing_messages_decorator
    @listing_messages_decorator = ListingMessagesDecorator.new(current_user.listing_messages, current_user)
  end

end
