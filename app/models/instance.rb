class Instance < ActiveRecord::Base
  attr_accessible :name, :site_name, :description, :tagline, :support_email, :contact_email,
                  :phone_number, :support_url, :blog_url, :twitter_url, :facebook_url, :meta_title,
                  :domains_attributes, :theme_attributes

  has_one :theme, class_name: 'InstanceTheme', dependent: :destroy

  has_many :companies
  has_many :locations, :through => :companies
  has_many :listings, :through => :locations
  has_many :users
  has_many :domains
  has_many :pages
  has_many :email_templates
  belongs_to :partner

  validates_presence_of :name

  accepts_nested_attributes_for :domains, :reject_if => proc { |params| params[:name].blank? }
  accepts_nested_attributes_for :theme, reject_if: proc { |params| params[:name].blank? }
  delegate :service_fee_percent, to: :partner,  allow_nil: true

  DEFAULT_INSTANCE_NAME = 'DesksNearMe'

  def is_desksnearme?
    self.name == DEFAULT_INSTANCE_NAME
  end

  def find_mailer_for(view_context, options = {})
    default_options = { template: view_context.action_name }
    options = default_options.merge!(options)

    details = {instance: self, handlers: [:liquid], formats: [:html, :text]}
    template_name = options[:template]
    template_prefix = view_context.lookup_context.prefixes.first

    template = EmailResolver.instance.find_mailers(template_name, template_prefix, false, details).first

    raise "Can't find mailer for #{template_prefix}/#{template_name}!" if template.nil?

    return template
  end

  def to_liquid
    InstanceDrop.new(self)
  end

  def self.default_instance
    self.where(name: DEFAULT_INSTANCE_NAME).first
  end

  def self.find_for_request(request)
    host = request.host.gsub(/^www\./, "")
    joins(:domains).where('domains.name LIKE ?', host).first
  end
end
