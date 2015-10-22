Spree::Zone.class_eval do
  include Spree::Scoper

  belongs_to :company

  _validators.reject!{ |key, _| key == :name }

  _validate_callbacks.each do |callback|
    callback.raw_filter.attributes.delete :name if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
  end

  validates :name, presence: true, uniqueness: {scope: [:instance_id, :company_id, :partner_id, :user_id]}
  validate :validate_zone_member

  def validate_zone_member
    member = members.first
    if !member.nil? && member.zoneable_type == 'Spree::Country' && member.zoneable_id.nil?
      errors.add(:country_ids, I18n.t('errors.messages.blank'))
    end

    if member.nil? || member.zoneable_type == 'Spree::State' && member.zoneable_id.nil?
      errors.add(:state_ids, I18n.t('errors.messages.blank'))
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

  def country_ids
    if kind == 'country'
      members.map(&:zoneable_id)
    else
      []
    end
  end

  def state_ids
    if kind == 'state'
      members.map(&:zoneable_id)
    else
      []
    end
  end

  def countries_json
    out = []
    if kind == 'country'
      out = members.map { |m| { id: m.zoneable.id, name: m.zoneable.name }}
    end
    JSON.generate(out)
  end

  def states_json
    out = []
    if kind == 'state'
      out = members.map { |m| { id: m.zoneable.id, name: m.zoneable.name }}
    end
    JSON.generate(out)
  end

end
