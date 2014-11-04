class Domain < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  # attr_accessible :name, :target, :target_id, :target_type, :secured

  attr_accessor :certificate_body, :private_key, :certificate_chain

  state_machine :state, initial: :unsecured do
    event :prepare_elb do
      transition :unsecured => :preparing
    end

    event :elb_created do
      transition :preparing => :elb_secured
    end

    event :error do
      transition :preparing => :error
    end
  end

  belongs_to :target, :polymorphic => true

  before_validation lambda { self.name = self.name.try(:strip) }

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :deleted_at
  validates_length_of :name, :maximum => 150
  validates :name, domain_name: true
  validates_presence_of :certificate_body, if: :prepared_for_elb?
  validates_presence_of :private_key, if: :prepared_for_elb?

  before_destroy :prevent_destroy_if_only_child
  before_destroy :delete_elb, if: :elb_secured?
  after_save :create_elb, if: :prepared_for_elb?

  validates_presence_of :target_type
  validates_each :name do |record, attr, value|
    if value =~ /^(www\.)?desksnear\.me$/i
      record.errors[:name] << "This domain is not available."
    end
  end

  scope :secured, -> { where(secured: true) }

  delegate :white_label_enabled?, :to => :target

  def self.where_hostname(hostname)
    domain = find_by(name: hostname)

    # Domain was not found, lets figure out the correct name
    unless domain
      parsed_url = Domainatrix.parse(hostname)

      # a.b.example.com => example.com, a.b.c.near-me.co.uk => near-me.co.uk
      without_subdomains = parsed_url.domain_with_public_suffix
      domain = find_by(name: without_subdomains)

      unless domain
        www_hostname = "www.#{without_subdomains}"
        domain = find_by(name: www_hostname)
      end
    end

    domain
  end

  def prepared_for_elb?
    # marked as secured but in unsecured state
    self.secured? and self.unsecured?
  end

  def delete_elb
    DeleteElbJob.perform(self.to_dns_name)
  end

  def create_elb
    self.prepare_elb!
    CreateElbJob.perform(self, self.certificate_body, self.private_key, self.certificate_chain)
  end

  def to_dns_name
    name.gsub('.', '-')
  end

  def deletable?
    not self.preparing?
  end

  def editable?
    (not self.secured? || self.error?)
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

  private

  def prevent_destroy_if_only_child
    errors.add(:name, "You won't be able to access admin if you delete your only domain") if near_me_domain?
    errors.blank?
  end

end
