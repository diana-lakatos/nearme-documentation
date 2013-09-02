class ListingMailer < InstanceMailer

  def share(listing, email, name, sharer, message=nil)
    @listing = listing
    @email = email
    @name = name
    @sharer = sharer
    @message = message
    @instance = listing.instance

    mailer = @instance.find_mailer_for(self)

    mail :to => "#{name} <#{email}>", :reply_to => "#{sharer.name} <#{sharer.email}>",
      :from => mailer.from,
      :subject => mailer.subject do |format|
      format.html { render view_context.action_name, instance: @instance }
      format.text { render view_context.action_name, instance: @instance }
    end
  end

  if defined? MailView
    class Preview < MailView
      def share
        FactoryGirl.create(:user) unless User.first
        FactoryGirl.create(:listing) unless Listing.first
        FactoryGirl.create(:instance) unless Instance.first
        ::ListingMailer.share(Listing.first, User.first.email, User.first.name, User.last, "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
      end
    end
  end

end
