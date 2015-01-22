Spree::Zone.class_eval do
  include Spree::Scoper

  belongs_to :company

  _validators.reject!{ |key, _| key == :name }

  _validate_callbacks.reject! do |callback|
    callback.raw_filter.attributes.delete :name if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
  end

  validates :name, presence: true, uniqueness: {scope: [:instance_id, :company_id, :partner_id, :user_id]}

  validate  :list_of_countries_or_states_cannot_be_empty


  def list_of_countries_or_states_cannot_be_empty
    if self.members.blank?
      errors.add(:kind, :members_missing)
    end
  end

  def country_ids=(ids)
    ids = ids.split(',') if ids.class == String
    zone_members.destroy_all
    ids.reject{ |id| id.blank? }.map do |id|
      member = Spree::ZoneMember.new
      member.zoneable_type = 'Spree::Country'
      member.zoneable_id = id
      members << member
    end
  end

  def state_ids=(ids)
    ids = ids.split(',') if ids.class == String
    zone_members.destroy_all
    ids.reject{ |id| id.blank? }.map do |id|
      member = Spree::ZoneMember.new
      member.zoneable_type = 'Spree::State'
      member.zoneable_id = id
      members << member
    end
  end
end
