class ListingsController < ApplicationController
  before_action :authenticate_user!, only: [:ask_a_question], if: :not_community?
  before_action :find_listing, only: [:show, :ask_a_question, :occurrences, :booking_module], if: :not_community?
  before_action :find_location, only: [:show, :ask_a_question], if: :not_community?
  before_action :find_transactable_type, only: [:show, :booking_module, :ask_a_question], if: :not_community?
  before_action :find_siblings, only: [:show, :ask_a_question], if: :not_community?
  before_action :redirect_if_no_access_granted, only: [:show, :ask_a_question], if: :restricted_access?
  before_action :redirect_if_listing_inactive, only: [:show, :ask_a_question], if: :not_community?
  before_action :redirect_if_non_canonical_url, only: [:show], if: :not_community?
  before_action :assign_transactable_type_id_to_lookup_context, if: :not_community?

  before_action :find_project, only: [:show], if: :is_community?
  before_action :redirect_if_draft, only: [:show], if: :is_community?
  before_action :build_comment, only: [:show], if: :is_community?

  def show
    if !PlatformContext.current.instance.is_community?
      @section_name = 'listings'

      @listing.track_impression(request.remote_ip)
      @reviews = @listing.reviews.paginate(page: params[:reviews_page])

      @rating_questions = RatingSystem.active_with_subject(RatingConstants::TRANSACTABLE).try(:rating_questions)
    else
      @feed = ActivityFeedService.new(@transactable)
      @followers = @transactable.feed_followers.paginate(pagination_params)
      @collaborators = @transactable.collaborating_users.paginate(pagination_params)
    end
    respond_to :html
  end

  def booking_module
    restore_initial_bookings_from_stored_reservation
    @collapsed = params[:collapsed] == 'true' ? true : false
    @location = @listing.location
    if @listing.action_type
      @action_type = @listing.action_type.decorate

      action_type_template = if params[:unavailable].eql?('true')
                               'unavailable'
                             else
                               @action_type.object.class.name.demodulize.underscore
                             end

      render template: "listings/action_types/#{action_type_template}", layout: false
    end
  end

  def ask_a_question
    render :show
  end

  def occurrences
    occurrences = @listing.next_available_occurrences(10, params)
    render json: occurrences, root: false
  end

  private

  def find_listing
    @listing = Transactable.with_deleted.friendly.find(params[:id]).decorate
  rescue
    # We used to use to_param set as $id-$name.parameterize, so
    # we're assuming the first - will separate id from the parameterized name.
    #
    if params[:id].blank? && params[:location_id].present?
      redirect_to(Location.friendly.find(params[:location_id]).listings.searchable.first.try(:decorate).try(:show_path) || '/') && return
    end
    old_id = params[:id].split('-').first
    old_slug = params[:id].split('-').try(:[], 1..-1).try(:join, '-')

    @listing = Transactable.find_by(id: old_id).presence || Transactable.find_by(slug: old_slug)
    if @listing.present?
      redirect_to @listing.decorate.show_path, status: 301
    elsif (location = Location.friendly.find(params[:id])).present?
      redirect_to(location.listings.searchable.first.try(:decorate).try(:show_path) || '/') && return
    else
      redirect_to request.referer.presence || search_path, status: 301
    end
  end

  def find_location
    @location = @listing.location
    redirect_to @listing.show_path, status: 301 if params[:location_id].present? && params[:location_id] != @location.slug
  end

  def find_transactable_type
    @transactable_type = @listing.transactable_type
    if params[:transactable_type_id].present? && !(params[:transactable_type_id] == @transactable_type.slug || params[:transactable_type_id].to_i == @transactable_type.id)
      redirect_to @listing.show_path, status: 301
    end
  end

  def find_siblings
    @listing_siblings = @location.listings.includes(:transactable_type).where.not(id: @listing.id)
    @listing_siblings = if @transactable_type.groupable_with_others?
                          @listing_siblings.for_groupable_transactable_types
                        else
                          @listing_siblings.for_transactable_type_id(@transactable_type.id)
                        end
    @listing_siblings = if current_user_can_manage_location?
                          # We only show non-draft listings even to the admin because otherwise weird errors can occur
                          # when showing him incomplete listings, especially if he tries to book it
                          @listing_siblings.active
                        else
                          @listing_siblings.searchable
                        end
  end

  def redirect_if_listing_inactive
    if @listing.deleted? || @listing.draft?
      flash[:warning] = t('flash_messages.listings.listing_inactive', address: @listing.address)
      if @listing_siblings.any?
        redirect_to @listing_siblings.first.decorate.show_path
      else
        redirect_to search_path(loc: @listing.location.address, q: @listing.name)
      end
    elsif @listing.disabled?
      if current_user_can_manage_listing?
        flash.now[:warning] = t('flash_messages.listings.listing_disabled_but_admin')
      else
        if @listing_siblings.any?
          flash[:warning] = t('flash_messages.listings.listing_disabled')
          redirect_to @listing_siblings.first.decorate.show_path
        else
          redirect_to search_path(loc: @listing.location.address, q: @listing.name)
        end
      end
    end
  end

  def redirect_if_no_access_granted
    unless current_user && (current_user.can_manage_listing?(@listing) || @listing.is_collaborator?(current_user))
      flash[:warning] = t('flash_messages.listings.no_longer_have_access')
      redirect_to root_path
    end
  end

  def current_user_can_manage_location?
    user_signed_in? && (current_user.can_manage_location?(@location) || current_user.instance_admin?)
  end

  def current_user_can_manage_listing?
    user_signed_in? && (current_user.can_manage_listing?(@listing) || current_user.instance_admin?)
  end

  def restore_initial_bookings_from_stored_reservation
    if params[:restore_reservations].to_i == @listing.id && session[:stored_order_transactable_id]
      @form_trigger = session[:stored_order_trigger][@listing.id.to_s].presence || 'Book'
      @initial_bookings = session[:stored_order_bookings][@listing.id]
    else
      @initial_bookings = {}
    end
  end

  def redirect_if_non_canonical_url
    redirect_to @listing.show_path(params.except(:format, :location_id, :controller, :action, :id, :transactable_type_id)), status: 301 unless [@listing.show_path, @listing.show_path(language: I18n.locale)].include?(request.path)
  end

  def is_community?
    PlatformContext.current.instance.is_community?
  end

  def not_community?
    !is_community?
  end

  def restricted_access?
    not_community? && @listing.transactable_type.access_restricted_to_invited?
  end

  # Community methods

  def find_project
    @transactable = Transactable.find(params[:id]).decorate
  rescue ActiveRecord::RecordNotFound
    @transactable = Transactable.find(Project.find(params[:id]).transactable_id).decorate
    redirect_to @transactable.show_path, status: 301
  end

  def redirect_if_draft
    redirect_to root_url, notice: I18n.t('draft_project') if @transactable.draft.present? && @transactable.creator != current_user
  end

  def build_comment
    @comment = @transactable.comments.build
    @comments = @transactable.comments.includes(:user).order('created_at DESC')
  end

  def pagination_params
    {
      page: 1,
      per_page: ActivityFeedService::Helpers::FOLLOWED_PER_PAGE
    }
  end
end
