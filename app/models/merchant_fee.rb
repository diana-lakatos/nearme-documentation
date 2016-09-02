class MerchantFee < ChargeType
  before_validation :set_mandatory_attributes

  def set_mandatory_attributes
    self.status = 'mandatory'
    self.commission_receiver = 'mpo'
  end
end
