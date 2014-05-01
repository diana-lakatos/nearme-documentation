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
        availability_rules_text: :string,
        delta: :boolean,
        minimum_booking_minutes: :integer,
        confirm_reservations: :boolean,
        rank: :integer,
        last_request_photos_sent_at: :datetime,
      }.each do |attr_name, attr_type|
        tta = TransactableTypeAttribute.where(transactable_type_id: @transactable_type.id, name: attr_name).first.presence || @transactable_type.transactable_type_attributes.build
        default = case attr_name
                  when :quantity
                    1
                  when :confirm_reservations, :delta, :listings_public
                    true
                  when :free, :hourly_reservations
                    false
                  when :rank
                    0
                  else
                    nil
                  end
        public_flag =  case  attr_name
                       when :listing_type, :quantity, :capacity, :confirm_reservations, :name, :description
                         true
                       else
                         false
                       end
        html_tag = case attr_name
                   when :confirm_reservations
                     :switch
                   else
                     :input
                   end

        validation_rules = case attr_name
                           when :hourly_reservations
                             { :inclusion => { :in => [true, false], :message => "must be selected" , :allow_nil => false } }
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
                              input_html_options: { :class => "mini" },
                              hint: "How many people does your #{PlatformContext.current.instance.bookable_noun} accommodate?",
                              placeholder: 1,
                              input_html_options: { :class => "mini" }
                            }
                          when :listing_type
                            {
                              html_tag: "select",
                              prompt: "",
                              valid_values: ["Shared Desks", "Meeting Room", "Private Office", "Salon Booth"],
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
          html_tag: html_tag,
          public: public_flag,
          default_value: default,
          validation_rules: validation_rules,
          valid_values: [],
          input_html_options: {}
        }.merge(rest_attributes)
        tta.save!
      end
    end
  end
end
