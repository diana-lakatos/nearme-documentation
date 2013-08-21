require 'mail_view'

class DesksNearMeMailer < ActionMailer::Base
  append_view_path EmailResolver.instance

  include ActionView::Helpers::TextHelper
  helper :listings, :reservations

  def mail(headers = {}, &block)
    lookup_context.class.register_detail(:instance) { nil }
    super
  end
end
