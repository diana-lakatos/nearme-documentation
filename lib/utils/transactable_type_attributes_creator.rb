module Utils
  class TransactableTypeAttributesCreator

    def initialize(transactable_type)
      @transactable_type = transactable_type
    end

    def create_listing_attributes!
      {
        name: :string,
        description: :string,
        listing_type: :string,
        quantity: :integer,
        capacity: :integer,
        delta: :boolean,
        minimum_booking_minutes: :integer,
        rank: :integer,
        last_request_photos_sent_at: :datetime,
      }.each do |attr_name, attr_type|
        tta = TransactableTypeAttribute.where(transactable_type_id: @transactable_type.id, name: attr_name).first.presence || @transactable_type.transactable_type_attributes.build

        default = case attr_name
                  when :quantity
                    1
                  when :delta, :listings_public
                    true
                  when :rank
                    0
                  else
                    nil
                  end
        public_flag =  case  attr_name
                       when :listing_type, :quantity, :capacity, :name, :description
                         true
                       else
                         false
                       end

        validation_rules = case attr_name
                           when :quantity
                             { :presence => {}, :numericality => { greater_than: 0, only_integer: true } }
                           when :description
                             { :length => { :maximum => 250 }, :presence => {} }
                           when :name
                             { :length => { :maximum => 50 }, :presence => {} }
                           when :listing_type
                             { :presence => {} }
                           else
                             {}
                           end
        rest_attributes = case attr_name
                          when :quantity
                            {
                              label:  'Quantity available',
                              input_html_options: { :class => "mini" },
                              hint: "How many of this type of #{PlatformContext.current.instance.bookable_noun} do you have available?",
                              placeholder: 2

                            }
                          when :capacity
                            {
                              hint: "How many people does your #{PlatformContext.current.instance.bookable_noun} accommodate?",
                              placeholder: 1,
                              input_html_options: { :class => "mini" }
                            }

                          when :listing_type
                            {
                              html_tag: "select",
                              prompt: "",
                              valid_values: ["Desk", "Meeting Room", "Office Space", "Salon Booth"],
                              input_html_options: { :class => 'selectpicker' },
                              label: "Desk type"
                            }
                          when :name
                            {
                              label: "#{PlatformContext.current.instance.bookable_noun} name"
                            }
                          when :description
                            {
                              label: "#{PlatformContext.current.instance.bookable_noun} description"
                            }
                          else
                            {}
                          end
        tta.attributes = {
          name: attr_name,
          attribute_type: attr_type.to_s,
          html_tag: 'input',
          public: public_flag,
          default_value: default,
          validation_rules: validation_rules,
          valid_values: [],
          input_html_options: {}
        }.merge(rest_attributes)
        tta.save!
      end
    end

    def create_buy_sell_attributes!
    end

  end

end
