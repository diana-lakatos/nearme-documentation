module ShippoApi
  class ShippoParameterMissing < StandardError
  end

  class ShippoUnknownParameterType < StandardError
  end

  class ShippoObject
    def set_params_from_hash(options)
      @options = options.each { |k, v| options[k] ||= '' }

      @required_params.each do |required_param|
        if !options.has_key?(required_param)
          raise ShippoParameterMissing.new required_param
        end

        singleton_class.class_eval do; attr_accessor required_param.to_s; end
        send("#{required_param.to_s}=", options[required_param])
      end
    end

    def to_hash
      @options
    end
  end

  class ShippoAddressInfo < ShippoObject
    PERMANENT_OPTIONS = {
      :object_purpose => 'PURCHASE',
      :street_no => ""
    }
    REQUIRED_PARAMS = [:object_purpose, :name, :company, :street1, :street_no, :street2, :city, :state, :zip, :country, :phone, :email]


    def initialize(purpose, spree_object, package)
      if purpose == :send_to
        address_object = spree_object
        options = {}

        options[:name] = "#{address_object.first_name} #{address_object.last_name}"
        options[:company] = address_object.company
        options[:street1] =  address_object.address1
        options[:street2] = address_object.address2
        options[:city] = address_object.city
        options[:state] = address_object.try(:state).try(:abbr)
        options[:zip] = address_object.zipcode
        options[:country] = address_object.try(:country).try(:iso)
        options[:phone] = address_object.phone
        options[:email] = package.order.user.email
      elsif purpose == :send_from
        stock_location = spree_object
        options = {}

        # We take the info instead from the user's first company as the address_object
        # in the current implementation will not have the info set
        products = package.contents.map(&:variant).map(&:product).compact.uniq
        creator_user = products.try(:first).try(:user)
        company = creator_user.try(:companies).try(:first)

        if company.present?
          options[:name] = creator_user.name
          options[:company] = company.name
          options[:street1] =  company.street
          options[:street2] = ''
          options[:city] = company.city
          options[:state] = company.state_code
          options[:zip] = company.postcode
          options[:country] = company.iso_country_code
          options[:phone] = creator_user.phone
          options[:email] = creator_user.email
        end
      else
        raise ShippoUnknownParameterType options.class.to_s
      end

      options = options.merge(PERMANENT_OPTIONS)
      @required_params = REQUIRED_PARAMS

      set_params_from_hash(options)
    end
  end

  class ShippoParcelInfo < ShippoObject
    REQUIRED_PARAMS = [:length, :width, :height, :distance_unit, :weight, :mass_unit]

    def initialize(options)
      if !options.is_a?(Hash)
        package = options
        options = {}
        options[:length] = package.contents.first.try(:variant).try(:depth)
        options[:width] = package.contents.first.try(:variant).try(:width)
        options[:height] = package.contents.first.try(:variant).try(:height)
        options[:distance_unit] = :in
        options[:weight] = package.weight
        options[:mass_unit] = :oz
      end

      @required_params = REQUIRED_PARAMS

      set_params_from_hash(options)
    end
  end

  class ShippoCustomsItemInfo < ShippoObject
    REQUIRED_PARAMS = [:description, :quantity, :net_weight, :mass_unit, :value_amount, :value_currency, :origin_country]

    def initialize(options)
      @required_params = REQUIRED_PARAMS

      set_params_from_hash(options)
    end
  end

  class ShippoCustomsDeclarationInfo < ShippoObject
    PERMANENT_OPTIONS = {
      :contents_type => "MERCHANDISE",
      :non_delivery_option => "RETURN",
    }
    REQUIRED_PARAMS = [:contents_type, :contents_explanation, :non_delivery_option, :certify, :certify_signer, :items]

    def initialize(options)
      @required_params = REQUIRED_PARAMS

      options = options.merge(PERMANENT_OPTIONS)

      set_params_from_hash(options)
    end
  end

  class ShippoTransactionResultInfo < ShippoObject
    REQUIRED_PARAMS = [:label_url, :tracking_number]

    def initialize(options)
      @required_params = REQUIRED_PARAMS

      set_params_from_hash(options)
    end
  end

  class ShippoApi
    MAX_GET_RATE_ATTEMPTS = 5
    MAX_BUY_RATE_ATTEMPTS = 5

    def initialize(username, password)
      Shippo::api_user = username
      Shippo::api_pass = password
    end

    def self.verify_connection(instance_params)
      begin
        if instance_params[:shippo_username].present? && instance_params[:shippo_password].present?
          Shippo.api_user = instance_params[:shippo_username]
          Shippo.api_pass = instance_params[:shippo_password]
          Shippo::Transaction.all
        end
        true
      rescue Shippo::ConnectionError
        false
      end
    end

    def get_rates(address_from_info, address_to_info, parcel_info, customs_item_info, customs_declaration_info)
      default_result_rates = []
      result_rates = default_result_rates

      address_from = Shippo::Address.create(address_from_info.to_hash)
      address_to = Shippo::Address.create(address_to_info.to_hash)
      parcel = Shippo::Parcel.create(parcel_info.to_hash)
      customs_item = nil
      customs_declaration = nil

      if !customs_item_info.nil? && !customs_declaration_info.nil?
        customs_item = Shippo::Customs_Item.create(customs_item_info.to_hash)
        customs_declaration = Shippo::Customs_Declaration.create(customs_declaration_info.to_hash.merge({ :items => customs_item['object_id'] }))
      end


      shipment_info = {
        :object_purpose => 'PURCHASE',
        :submission_type => 'DROPOFF',
        :address_from => address_from,
        :address_to => address_to,
        :parcel => parcel
      }

      if !customs_declaration.nil?
        shipment_info.merge!({ :customs_declaration => customs_declaration })
      end

      shipment = Shippo::Shipment.create(shipment_info)

      attempts = 0
      while ["QUEUED","WAITING"].include?(shipment.object_status) && (attempts < MAX_GET_RATE_ATTEMPTS) do
        shipment = Shippo::Shipment.get(shipment["object_id"])
        attempts += 1
      end

      result_rates = shipment.rates()

      result_rates
    rescue
      return default_result_rates
    end

    def purchase_rate(shippo_rate_id)
      default_result_purchase = nil
      result_purchase = default_result_purchase

      transaction = Shippo::Transaction.create(:rate => shippo_rate_id)

      attempts = 0
      while ["QUEUED","WAITING"].include?(transaction.object_status) && (attempts < MAX_BUY_RATE_ATTEMPTS) do
        transaction = Shippo::Transaction.get(transaction["object_id"])
        attempts += 1
      end

      if transaction.object_status != "ERROR"
        result_purchase = ShippoTransactionResultInfo.new(:label_url => transaction.label_url, :tracking_number => transaction.tracking_number)
      end

      result_purchase
    rescue
      return default_result_purchase
    end

  end
end

