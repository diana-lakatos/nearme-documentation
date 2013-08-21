require 'email_resolver'

class EmailTemplate < ActiveRecord::Base
  belongs_to :instance
  attr_accessible :handler, :html_body, :text_body, :path, :partial, :subject, :to, :from, :bcc, :reply_to, :subject

  validates :html_body, :text_body, :path, :instance_id, presence: true
  # validates :from, email: true

  after_save do
    EmailResolver.instance.clear_cache
  end

  def locale
    "en"
  end

  def handler
    "liquid"
  end

  def liquid_subject(locals = {})
    template = Liquid::Template.parse(self.subject)
    template.render(locals)
  end
end
