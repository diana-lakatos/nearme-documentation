class ReservationIssueLogger < IssueLogger
  def self.rejected_with_reason(reservation, user)
    body = I18n.t('desk.reservation_rejected_body', reason: reservation.rejection_reason, user: user.name)
    log_issue(I18n.t('desk.reservation_rejected_title'), reservation.owner.email, body)
  end
end
