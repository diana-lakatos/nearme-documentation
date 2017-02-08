require 'domainatrix'

class Domain < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context

  REDIRECT_CODES = [301, 302]

  has_many :reverse_proxies
  belongs_to :aws_certificate

  state_machine :state, initial: :unsecured do
    event :prepare_elb do
      transition [:unsecured, :failed] => :preparing
    end

    event :elb_created do
      transition [:failed, :preparing] => :elb_secured
    end

    event :elb_updated do
      transition [:elb_secured, :failed] => :elb_secured
    end

    event :failed do
      transition [:failed, :elb_secured, :preparing] => :failed
    end
  end

  belongs_to :target, polymorphic: true, touch: true
  belongs_to :instance

  before_validation -> { self.name = name.try(:strip) }

  validates_presence_of :name
  validates_presence_of :aws_certificate_id, if: proc { |d| d.https_required? && !d.near_me_domain? }
  validates_uniqueness_of :name, scope: :deleted_at
  validates_length_of :name, maximum: 150
  validates_length_of :google_analytics_tracking_code, maximum: 15

  validates :name, domain_name: true
  validate :validate_default_domain_presence

  before_destroy :prevent_destroy_if_only_child
  before_save :ensure_load_balancer_name

  after_save :mark_as_default
  after_commit :clear_cache

  validates_presence_of :target_type

  validates :redirect_code, inclusion: { in: REDIRECT_CODES }, allow_blank: true
  validates :redirect_to, presence: true, if: :redirect_code?

  scope :secured, -> { where(secured: true) }
  scope :default, -> { where(use_as_default: true) }

  delegate :white_label_enabled?, to: :target

  mount_uploader :uploaded_robots_txt, RobotsTxtUploader
  mount_uploader :generated_sitemap, SitemapUploader
  mount_uploader :uploaded_sitemap, SitemapUploader

  def self.where_hostname(hostname)
    domain_lookup(hostname).each do |host|
      break if @domain = find_by(name: host)
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

  def ensure_load_balancer_name
    self.load_balancer_name = to_dns_name if load_balancer_name.nil?
  end

  def prepared_for_elb?
    # marked as secured but in unsecured state
    https_required? && unsecured? && !near_me_domain?
  end

  def https_required?
    secured?
  end

  def can_be_elb_managed?
    !near_me_domain? && https_required?
  end

  def to_dns_name
    name.gsub('.', '-')
  end

  def deletable?
    !(use_as_default || near_me_domain?)
  end

  def editable?
    !near_me_domain?
  end

  def url
    https_required? ? 'https://' + name : 'http://' + name
  end

  def white_label_company?
    'Company' == target_type
  end

  def instance?
    'Instance' == target_type
  end

  def partner?
    'Partner' == target_type
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
    if use_as_default && target_type.try(:include?, 'Instance')
      target.domains.default.where.not(id: id).update_all(use_as_default: false)
    end
  end

  def validate_default_domain_presence
    if !use_as_default && target_type.try(:include?, 'Instance') && target.domains.default.where.not(id: id).count.zero?
      errors.add :use_as_default, 'At least one domain needs to be default one'
    end
  end

  def prevent_destroy_if_only_child
    errors.add(:name, "You won't be able to access admin if you delete your only domain") if near_me_domain?
    errors.blank?
  end
end
