# frozen_string_literal: true
class ShoppingCart < ActiveRecord::Base
  include Modelable

  belongs_to :user, -> { with_deleted }

  has_many :orders, dependent: :destroy
  has_many :reservations, -> { where(type: 'Reservation') }

  accepts_nested_attributes_for :reservations

  def self.get_for_user(user)
    user.current_shopping_cart
  end

  def to_liquid
    @shopping_cart_liquid ||= ShoppingCartDrop.new(self)
  end

  # FIXME: nead a cleaner solution - for now it's used by Form Object
  # to populate inputs
  def orders_open_struct
    hash = {}
    ReservationType.pluck(:parameterized_name, :id).each do |reservation_types_array|
      hash[reservation_types_array[0]] = OpenStruct.new(
        reservations: reservations.select { |order| order.reservation_type_id == reservation_types_array[1] }
      )
    end
    hash.each_key { |k| hash[k][:real_model] = self }
    OpenStruct.new(hash)
  end

  # FIXME: nead a cleaner solution - for now it's used by Form Object
  # to sync model with form after validation passes
  def orders_open_struct=(open_struct)
    hash = open_struct.to_h
    hash.delete(:real_model)
    orders_open_structs = hash.values.flatten
    self.reservations = orders_open_structs.map(&:reservations).flatten.tap do |collection|
      collection.each do |o|
        o.host_fee_line_items.destroy_all
        o.service_fee_line_items.destroy_all
      end
    end
  end
end
