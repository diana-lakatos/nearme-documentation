class BuySell::UpdateBlankUserFieldsService

  def initialize(user)
    @user = user
  end

  def update_blank_user_fields(bill_address)
    @user.first_name = bill_address.firstname if @user.first_name.blank?
    @user.last_name = bill_address.lastname if @user.last_name.blank?
    @user.company_name = bill_address.company if @user.company_name.blank?
    @user.country_name = bill_address.country.name if @user.country_name.blank? && bill_address.try(:country).try(:name).present?

    @user.save(validate: false)
  end

end

