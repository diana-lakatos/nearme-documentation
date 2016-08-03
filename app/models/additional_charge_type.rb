class AdditionalChargeType < ChargeType
  belongs_to :additional_charge_type_target, polymorphic: true, touch: true, foreign_key: 'charge_type_target_id', foreign_type: 'charge_type_target_type'

  def additional_charge_type_targets
    TransactableType.all.map {|t| [t.name, t.signature] }.unshift(["Instance", current_instance.signature])
  end

  def additional_charge_type_target=(attribute)
    self.charge_type_target_id, self.charge_type_target_type = attribute.split(',')
  end
end
