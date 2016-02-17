class Dashboard::UserBidsController < Dashboard::BaseController

  def index
    state = params[:state] == 'archived' ? [:rejected, :cancelled_by_guest, :expired] : params[:state] || :unconfirmed
    @offers = current_user.bids.with_state(state).group_by(&:offer)
  end

  def show
    @bid = current_user.bids.find(params[:id])
    @offer = @bid.offer
  end


end