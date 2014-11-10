class PostActionMailerPreview < MailView

  def sign_up_verify
    ::PostActionMailer.sign_up_verify(User.where('users.verified_at is null').first)
  end

  def sign_up_welcome
    ::PostActionMailer.sign_up_welcome(User.last)
  end

  def list_draft
    ::PostActionMailer.list_draft(user_with_listing)
  end

  def created_by_instance_admin
    ::PostActionMailer.created_by_instance_admin(new_user_without_password, User.first)
  end

  def list
    ::PostActionMailer.list(user_with_listing)
  end

  def unsubscription
    ::PostActionMailer.unsubscription(User.last, 'recurring_mailer/request_photos')
  end

  def instance_created
    instance_admin = (InstanceAdmin.joins({:user => :listings}).first || InstanceAdmin.create(:instance_id => PlatformContext.current.instance.id, :user_id => Transactablefirst.creator.id))
    ::PostActionMailer.instance_created(instance_admin.instance, instance_admin.user, 'password')
  end

  def user_created_invitation
    ::PostActionMailer.user_created_invitation(User.last, 'password')
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
