class Dashboard::Company::UserAuctionsController < Dashboard::Company::BaseController
  before_filter :find_bid, except: :index

  def index
    state = params[:state] == 'archived' ? [:auction_cancelled, :case_resolved] : params[:state] || :auction_open
    @offers = current_user.offers.with_state(state).includes(:bids).where.not(bids: { id: nil })
  end

  def show
    @offer = @bid.offer
  end

  def reject
    if @bid.reject
      # WorkflowStepJob.perform(WorkflowStep::BidWorkflow::Rejected, @bid.id)
      # event_tracker.rejected_a_bid(@bid)
      flash[:deleted] = t('flash_messages.manage.bids.rejected')
    else
      flash[:error] = t('flash_messages.manage.bids.cant_reject')
    end
    redirect_to action: :index
  end

  def approve
    if @bid.confirmed?
      flash[:warning] = t('flash_messages.manage.bids.reservation_already_confirmed')
    else
      if @bid.confirm
        # WorkflowStepJob.perform(WorkflowStep::BidWorkflow::ManuallyConfirmed, @bid.id)
        # event_tracker.confirmed_a_booking(@reservation)
        # track_reservation_update_profile_informations
        # event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
        flash[:success] = t('flash_messages.manage.bids.reservation_confirmed')
      else
        flash[:error] = [
          t('flash_messages.manage.bids.reservation_not_confirmed'),
          *@bid.errors.full_messages
        ].join(' ')
      end
    end

    redirect_to action: :index
  end

  def find_bid
    @bid = current_user.offer_bids.find(params[:id])
  end

end