class Domain < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context

  REDIRECT_CODES = [301, 302]

  attr_accessor :certificate_body, :private_key, :certificate_chain

  state_machine :state, initial: :unsecured do
    event :prepare_elb do
      transition [:unsecured, :error] => :preparing
    end

    event :elb_created do
      transition :preparing => :elb_secured
    end

    event :prepare_elb_update do
      transition [:elb_secured, :error_update] => :preparing_update
    end

    event :elb_updated do
      transition :preparing_update => :elb_secured
    end

    event :error do
      transition :preparing => :error
    end

    event :error_update do
      transition :preparing_update => :error_update
    end
  end

  belongs_to :target, polymorphic: true, touch: true
  belongs_to :instance

  before_validation lambda { self.name = self.name.try(:strip) }

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :deleted_at
  validates_length_of :name, :maximum => 150
  validates_length_of :google_analytics_tracking_code, maximum: 15

  validates :name, domain_name: true
  validates_presence_of :certificate_body, if: :prepared_for_elb?
  validates_presence_of :private_key, if: :prepared_for_elb?
  validate :validate_default_domain_presence

  before_destroy :prevent_destroy_if_only_child
  before_destroy :delete_elb, if: :elb_secured?
  after_save :create_or_update_elb

  after_save :mark_as_default
  after_commit :clear_cache

  validates_presence_of :target_type

  validates :redirect_code, inclusion: { in: REDIRECT_CODES }, allow_blank: true
  validates :redirect_to, presence: true, if: :redirect_code?

  scope :secured, -> { where(secured: true) }
  scope :default, -> { where(use_as_default: true) }

  delegate :white_label_enabled?, :to => :target

  mount_uploader :uploaded_robots_txt, RobotsTxtUploader
  mount_uploader :generated_sitemap, SitemapUploader
  mount_uploader :uploaded_sitemap, SitemapUploader

  def self.where_hostname(hostname)
    domain_lookup(hostname).each do |host|
      break if @domain = includes(:target => :theme).where('name ilike ?', host).first
    end
    @domain
  end

  def self.domain_lookup(hostname)
    parsed_url = Domainatrix.parse(hostname)
    # a.b.example.com => example.com, a.b.c.near-me.co.uk => near-me.co.uk
    without_subdomains = parsed_url.domain_with_public_suffix
    www_hostname = "www.#{without_subdomains}"
    [hostname, without_subdomains, www_hostname]
  end

  def prepared_for_elb?
    # marked as secured but in unsecured state
    self.secured? && self.unsecured? && !near_me_domain?
  end

  def delete_elb
    DeleteElbJob.perform(self.to_dns_name)
  end

  def create_or_update_elb
    # Avoid endless loop because state_machine event methods are triggering after_save
    # except for when the state was nil and it's now unsecured (initial domain creation)
    return true if self.state_changed? && !(self.state_was.blank? && self.unsecured?)

    if can_be_elb_managed?
      # The load balancer does not exist either because it's in the initial state
      # or because the creation failed
      if self.unsecured? || self.error?
        self.prepare_elb!
        CreateElbJob.perform(self.id, self.certificate_body, self.private_key, self.certificate_chain)
      # The load balancer exists and has a certificate or exists but a certificate update has failed
      # and we also received a new certificate in the params from the user
      elsif (self.elb_secured? || self.error_update?) && self.certificate_body.present? && self.private_key.present?
        self.prepare_elb_update!
        UpdateElbJob.perform(self.id, self.certificate_body, self.private_key, self.certificate_chain)
      end
    end
  rescue
    # Ignore to allow state to be set in dev mode
    # In production it will avoid showing an error page
    # but the error will be visible in the column and the
    # message saved in the DB
  end

  def can_be_elb_managed?
    !near_me_domain? && self.secured?
  end

  def to_dns_name
    name.gsub('.', '-')
  end

  def deletable?
    not(preparing? || use_as_default || near_me_domain? || preparing_update?)
  end

  def editable?
    !self.near_me_domain?
  end

  def url
    secured? ? "https://" + name : "http://" + name
  end

  def white_label_company?
    "Company" == target_type
  end

  def instance?
    "Instance" == target_type
  end

  def partner?
    "Partner" == target_type
  end

  def near_me_domain?
    name =~ /^(.*)\.near-me\.com$/
  end

  def redirect?
    redirect_code.present? && redirect_to.present?
  end

  def clear_cache
    (self.class.domain_lookup(name) + self.class.domain_lookup(name_was)).uniq.each do |hostname|
      Rails.cache.delete "domains_cache_#{hostname}"
    end
  end

  def sitemap
    SitemapService.content_for(self)
  end

  def robots
    RobotsTxtService.content_for(self)
  end

  private

  def mark_as_default
    if use_as_default && target_type.try(:include?, "Instance")
      target.domains.default.where.not(id: self.id).update_all(use_as_default: false)
    end
  end

  def validate_default_domain_presence
    if !use_as_default && target_type.try(:include?, "Instance") && target.domains.default.where.not(id: self.id).count.zero?
      errors.add :use_as_default, "At least one domain needs to be default one"
    end
  end

  def prevent_destroy_if_only_child
    errors.add(:name, "You won't be able to access admin if you delete your only domain") if near_me_domain?
    errors.blank?
  end

end
