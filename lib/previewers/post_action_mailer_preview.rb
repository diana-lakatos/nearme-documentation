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

  def created_by_instance_admin
    ::PostActionMailer.created_by_instance_admin(PlatformContext.new, new_user_without_password, User.first)
  end

  def list
    ::PostActionMailer.list(PlatformContext.new, user_with_listing)
  end

  private

  def user_with_listing
    @user ||= (User.all.select{|u| !u.listings.count.zero?}.sample || FactoryGirl.create(:listing).user)
  end
  
  def new_user_without_password
    @u ||= User.where(:email => 'nopassworddoe@example.com').first.presence || User.new(:name => 'John no password Doe', :email => 'nopassworddoe@example.com')
    @u.save!(:validate => false) if @u.new_record?
    @u

  end

end
