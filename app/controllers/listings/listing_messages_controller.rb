class Listings::ListingMessagesController < ApplicationController

  before_filter :find_listing
  before_filter :redirect_to_login, only: [:new]
  before_filter :authenticate_user!, except: [:new]

  def new
    @listing_message = @listing.listing_messages.new
    setup_listing_message
  end

  def create
    @listing_message = @listing.listing_messages.new(params[:listing_message])
    setup_listing_message
    if @listing_message.save
      # User who is recipient of this listing message thread must have refreshed its unread counter cache
      set_unread_message_counters_for(@listing_message.recipient)

      @listing_message.send_notification(platform_context)
      flash[:notice] = t('flash_messages.listing_messages.message_sent')
      redirect_to listing_messages_path
      render_redirect_url_as_json if request.xhr?
    else
      if request.xhr?
        render :template => 'listings/listing_messages/new'
      else
        @listing_messages = ListingMessage.for_thread(@listing, @listing_message).by_created.decorate
        render :show
      end
    end
  end

  def show
    @show_listing_message = @listing.listing_messages.find(params[:id])
    @listing_message = @listing.listing_messages.new(replying_to_id: @show_listing_message.id)

    @listing_messages = ListingMessage.for_thread(@listing, @show_listing_message).by_created.decorate

    # All unread messages are marked as read
    to_mark_as_read = @listing_messages.select{|m| m.unread_for?(current_user)}
    ListingMessage.update_all({read: true},
                              {id: to_mark_as_read.map(&:id)})

    # User who has seen this listing message thread must have refreshed its unread counter cache
    # if there are some messages newly marked as read
    set_unread_message_counters_for(current_user) if to_mark_as_read.present?

    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
  end

  def archive
    @listing_message = @listing.listing_messages.find(params[:listing_message_id])
    column = @listing_message.archived_column_for(current_user)
    ListingMessage.update_all({column => true},
                              {owner_id: @listing_message.owner_id, listing_id: @listing.id})
    flash[:notice] = t('flash_messages.listing_messages.message_archived')
    redirect_to listing_messages_path
  end

  private

  def find_listing
    listing_scope = ['show', 'archive'].include?(action_name) ? Listing.with_deleted : Listing.scoped
    @listing = listing_scope.find(params[:listing_id])
  end

  def setup_listing_message
    @listing_message.author = current_user
    @listing_message.owner = if @listing_message.first_in_thread?
      current_user
    else
      @listing_message.previous_in_thread.owner
    end
    @listing_message.decorate
  end

  def redirect_to_login
    return if user_signed_in?
    session[:user_return_to] = ask_a_question_location_listing_url(@listing.location, @listing)
    redirect_to new_user_session_path
  end

  def set_unread_message_counters_for(user)
    actual_count = user.reload.decorate.unread_listing_message_threads.fetch.size
    user.unread_listing_message_threads_count = actual_count
    user.save!
  end

end
