require 'email_resolver'

class EmailTemplate < ActiveRecord::Base
  belongs_to :theme
  attr_accessible :handler, :html_body, :text_body, :path, :partial, :subject, :to, :from, :bcc, :reply_to, :subject

  validates :html_body, :text_body, :path, :theme_id, presence: true

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
    return if self.subject.to_s.empty?
    template = Liquid::Template.parse(self.subject)
    template.render(locals.stringify_keys!)
  end
end
