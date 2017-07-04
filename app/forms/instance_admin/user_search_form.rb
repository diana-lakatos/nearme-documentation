# frozen_string_literal: true
class InstanceAdmin::UserSearchForm < SearchForm
  property :q, virtual: true
  property :date, virtual: true
  property :filters, virtual: true
  property :item_type_id, virtual: true
  property :state, virtual: true
  property :profile_type, virtual: true

  def initialize
    super Object.new
  end

  def to_search_params
    result = {}

    # We don't want to include global admins
    result[:not_admin] = nil

    result[:by_search_query] = ["%#{q}%"] if q.present?

    result[:with_date] = [date_from_params] if date.present?

    result[:by_profile_type] = [item_type_id] if item_type_id.present?

    if profile_type == 'buyer'
      result[:buyers] = nil
    elsif profile_type == 'seller'
      result[:sellers] = nil
    end

    result[:is_guest] = nil if filters.try(:include?, 'guest')

    result[:is_host] = nil if filters.try(:include?, 'host')

    result[:banned] = nil if state.present? && state == 'banned'

    result[:deleted] = nil if state.present? && state == 'deleted'

    result[:active_users] = nil if state.blank? || state == 'active'

    result
  end
end
