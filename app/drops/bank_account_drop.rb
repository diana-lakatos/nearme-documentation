# frozen_string_literal: true
class BankAccountDrop < BaseDrop
  attr_reader :bank_account

  delegate :last4, to: :bank_account

  def initialize(bank_account)
    @bank_account = bank_account
  end

end
