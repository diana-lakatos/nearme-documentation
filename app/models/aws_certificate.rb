class AwsCertificate < ActiveRecord::Base
  scoped_to_platform_context
  auto_set_platform_context

  validates :name, presence: true
  validates :arn, uniqueness: true

  has_many :domains

  scope :active, -> { where('status = ? or certificate_type = ?', 'ISSUED', 'IAM') }
  scope :uploaded, -> { where(certificate_type: 'IAM') }
  scope :requests, -> { where(certificate_type: nil) }

  def confirmation_emails
    %w(webmaster postmaster administrator hostmaster admin)
      .map { |email| [email, name].join('@') }
  end

  def domain_list
    %w(www *)
      .map { |subdomain| [subdomain, name].join('.') }
  end
end
