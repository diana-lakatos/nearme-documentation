# frozen_string_literal: true
class MakeSureAllInstanceProfileTypesAreNamedCorrectly < ActiveRecord::Migration
  def up
    %w(seller default buyer).each do |type|
      InstanceProfileType.unscoped.where(profile_type: type).update_all(name: type.capitalize, parameterized_name: type)
    end
  end

  def down
  end
end
