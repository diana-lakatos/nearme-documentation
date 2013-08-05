class EmailTemplate < ActiveRecord::Base
  self.inheritance_column = nil

  belongs_to :instance
  attr_accessible :body, :from, :subject, :type

  validates :subject, :from, :body, :instance_id, :type, presence: true
  validates :from, email: true
  validate  :liquify_template

  def render(options = {})
    template.render(options.stringify_keys)
  end

  private

  def liquify_template
    Liquid::Template.parse(body)
  rescue Liquid::SyntaxError => error
    errors.add :template, error
  end

  def template
    Liquid::Template.parse(body)
  end
end
