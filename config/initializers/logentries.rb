if Rails.env.production?
  Rails.logger = Le.new('35b1c088-608a-4111-8eaf-5a6c4fe1ca1e')
end

