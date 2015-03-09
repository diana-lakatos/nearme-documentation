class UpdatePayoutStatusJob < Job

  def perform
    Payout.need_status_verification.find_each do |p|
      p.update_status
    end
  end

end


