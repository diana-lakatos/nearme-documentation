class MailingAddressPopulator

  def fetch
    Company.all.each do |company|
      next if company.mailing_address.to_s.strip.blank? || company.payments_mailing_address.present?

      begin
        address = Address.new
        # puts company.mailing_address
        address.address = company.mailing_address
        address.save!
      rescue
        next # Address was invalid
      end

      company.update_attribute(:mailing_address_id, address.id)
    end
  end

end
