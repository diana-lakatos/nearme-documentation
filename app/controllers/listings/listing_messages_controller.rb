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

    to_mark_as_read = @listing_messages.select{|m| m.unread_for?(current_user)}
    ListingMessage.update_all({read: true},
                              {id: to_mark_as_read.map(&:id)})
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
    @listing = Listing.find(params[:listing_id])
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

end
