class PostActionMailerPreview < MailView

  def sign_up_verify
    ::PostActionMailer.sign_up_verify(PlatformContext.new, User.where('users.verified_at is null').first)
  end

  def sign_up_welcome
    ::PostActionMailer.sign_up_welcome(PlatformContext.new, User.last)
  end

  def list_draft
    ::PostActionMailer.list_draft(PlatformContext.new, user_with_listing)
  end

  def list
    ::PostActionMailer.list(PlatformContext.new, user_with_listing)
  end

  private

  def user_with_listing
    User.all.select{|u| !u.listings.count.zero?}.sample || FactoryGirl.create(:listing).user
  end

end
