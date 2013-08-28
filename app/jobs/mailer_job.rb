# Base class for sending emails
#
# This encapsulates logic behind sending email, whether to do it immediately, or in background. In the second case,
# it communicates with Mailer class to determine when the email should be sent [ i.e. after 1 hour, 10 days etc ]
# 
# Arguments:
#
# arg1 - mailer class
# arg2 - method that sends email
# next args - arguments for the method from arg2
#
# Example Usage:
#
# we want to send notification for hosts that they need to confirm new reservation.
# This is how we do this:
#
# MailerJob.perform(ReservationMailer, :notify_host_with_confirmation, @reservation)
#
# Note:
#
# If we want to send email after specific time, the mailer class should define *CLASS* method run_at, which returns datetime [ or nil ]
# before which email should not be sent. Example:
#
# class AfterSignupEmail
# 
#   def help_offer(user)
#     mail to: user.email
#   end
#
#   protected
#
#   # please note self.run_at ! this has to be class method, not instance!!!
#   def self.run_at
#     Time.zone.now + 1.hour
#   end
# end
#
# this method will guarantee, that email will not be sent before certain datetime. Usage is the same:
#
# MailerJob.perform(AfterSignupMailer, :help_offer, @user)
#
# If we have many methods in Mailer class, and we want to specify emails that should be sent later, we can do
#
# Class AfterSignupEmail
#
#   def help_offer(user)
#     mail to: user.email
#   end
#
#   def other_email(user)
#     mail to: user.email
#   end
#   
#   protected
#
#   def self.run_at(method)
#     case method
#     when :help_offer
#       1.hour.from_now
#     else
#       nil
#     end
#   end
# end

class MailerJob < Job
  def initialize(mailer_class, mailer_method, *args)
    @mailer_class = mailer_class
    @mailer_method = mailer_method
    @args = args
  end

  def perform
    @mailer_class.send(@mailer_method, *@args).deliver
  end

  def delayed_job_options
    if @mailer_class.respond_to?(:run_at, true)
      # try to send method as parameter. If it didn't work, try to invoke the method without additional argument
      run_at = begin
         @mailer_class.send(:run_at, @mailer_method)
       rescue
         @mailer_class.send(:run_at)
       end
      run_at ? { :run_at => run_at } : super
    else
      super
    end
  end
end
