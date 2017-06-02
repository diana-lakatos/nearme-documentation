# frozen_string_literal: true
namespace :mycsn do
  desc 'Setup Mycsn'

  task import_carers: [:environment] do
    instance = Instance.find(5032)
    instance.set_context!
    EXTERNAL_ID = 0
    FIRST_NAME = 1
    LAST_NAME = 2
    GENDER = 3
    DOB = 4 # MM/DD/YYYY
    PHONE = 5
    MOBILE = 6
    EMAIL = 7
    PASSWORD = 8
    ADDRESS = 9
    SUBURB = 10
    POST_CODE = 11
    STATE = 12
    SERVICE_ADDRESS = 13
    LONGITUDE = 14
    LATITUDE = 15
    FIRST_LANG = 16
    LANGUAGES = 17
    SUMMARY_PROFILE = 18
    DETAILED_PROFILE = 19
    SKILLS = 20
    AGED_CARE = 21
    DISABILITY = 22
    CHILD_CARE = 23
    FIRST_AID = 24
    POLICE_CHECK = 25
    CHILDREN_CARE = 26
    DOMESTIC = 27
    PERSONAL = 28
    CERT_AGRED_CARE = 29
    CERT_DISABILITY = 30
    NON_SMOKER = 31
    STUDENT = 32
    AUS_RESIDENT = 33
    PET_OK = 34
    MORNING = 35
    AFTERNOON = 36
    EVENING = 37
    OVERNIGHT = 38
    WEEKEND = 39
    LIVEIN = 40
    FULL_TIME = 41
    PART_TIME = 42
    CASUAL = 43
    COOKING = 44
    DIS_TRAVEL = 45
    HOWHEAR = 46
    PAY_RATE = 47
    MONTHLY_NEWSLETTER = 48
    EMAIL_LIST = 49
    AGREE = 50
    HASABN = 51
    ABNNUM = 52
    DATE_CREATED = 53
    IP_ADDRESS = 54

    path = Rails.root.join('marketplaces', 'mycsn', 'carer_full_data.csv')
    emails = []
    CustomValidator.where(field_name: %w(languages how_did_you_hear)).destroy_all
    CSV.foreach(path, col_sep: ',') do |array|
      email = array[EMAIL].strip
      if email.include?('@')
        emails << email
        u = User.where('email ilike ?', email).first_or_initialize
        u.email = email
        if u.persisted?
          puts("#{email} exist, skipping")
          next
        else
          puts("importing: #{email}")
        end
        u.get_default_profile
        u.get_seller_profile
        u.password = SecureRandom.hex(12) unless u.encrypted_password.present?
        u.external_id = array[EXTERNAL_ID]
        u.first_name = array[FIRST_NAME].humanize
        u.last_name = array[LAST_NAME].humanize
        u.seller_profile.properties.gender = array[GENDER]
        u.seller_profile.properties.date_of_birth = begin
                                       Date.strptime(array[DOB], '%m/%d/%Y')
                                     rescue
                                       puts "\tInvalid DOB: #{array[DOB]}"
                                       nil
                                     end
        u.default_profile.properties.landline = array[PHONE]
        u.mobile_number = array[MOBILE]
        u.seller_profile.properties.physical_address_street = array[ADDRESS]
        u.seller_profile.properties.physical_address_post_code = array[POST_CODE]
        u.seller_profile.properties.physical_address_suburb = array[SUBURB]
        u.seller_profile.properties.physical_address_state = array[STATE]
        u.seller_profile.properties.physical_address_country = 'Australia'
        if array[LONGITUDE].present? && array[LATITUDE].present?
          u.current_address || u.build_current_address
          u.current_address.address = array[SERVICE_ADDRESS]
          u.current_address.longitude = array[LONGITUDE]
          u.current_address.latitude = array[LATITUDE]
        end
        u.seller_profile.properties.languages = (Array(array[FIRST_LANG]) + Array(array[LANGUAGES])).uniq

        u.seller_profile.properties.summary_profile = array[SUMMARY_PROFILE]&.gsub('_x000D_', '')
        u.seller_profile.properties.detailed_profile = array[SUMMARY_PROFILE]&.gsub('_x000D_', '') # on purpose! column missing
        if array[SKILLS]&.gsub('_x000D_', '').present?
          skills = u.seller_profile.customizations.where(custom_model_type: CustomModelType.find_by(name: 'Experiences')).first_or_initialize
          skills.properties.name = 'My Skills'
          skills.properties.description = array[SKILLS]&.gsub('_x000D_', '')
        end

        u.seller_profile.properties.aged_care_support = array[AGED_CARE] == 'on'
        u.seller_profile.properties.disability_support = array[DISABILITY] == 'on'
        u.seller_profile.properties.child_care = array[CHILD_CARE] == 'on'
        u.seller_profile.properties.verification_first_aid = array[FIRST_AID] == 'on'
        u.seller_profile.properties.verification_police_check = array[POLICE_CHECK] == 'on'
        u.seller_profile.properties.domestic_duties = array[DOMESTIC] == 'on'
        u.seller_profile.properties.personal_care = array[PERSONAL] == 'on'

        qualifications = u.seller_profile.customizations.where(custom_model_type: CustomModelType.find_by(name: 'Qualifications'))
        if array[CERT_AGRED_CARE] == 'on'
          aged_care = qualifications.detect { |q| q.properties.qualification == 'Certificate 3 Aged Care' } || u.seller_profile.customizations.where(custom_model_type: CustomModelType.find_by(name: 'Qualifications')).first_or_initialize
          aged_care.properties.qualification = 'Certificate 3 Aged Care'
        end
        if array[CERT_DISABILITY] == 'on'
          aged_care = qualifications.detect { |q| q.properties.qualification == 'Certificate 3 Disability' } || u.seller_profile.customizations.where(custom_model_type: CustomModelType.find_by(name: 'Qualifications')).first_or_initialize
          aged_care.properties.qualification = 'Certificate 3 Disability'
        end

        u.seller_profile.properties.non_smoker = array[NON_SMOKER] == 'on'
        u.seller_profile.properties.student = array[STUDENT] == 'on'
        u.seller_profile.properties.aus_resident = array[AUS_RESIDENT] == 'on'
        u.seller_profile.properties.pet_friendly = array[PET_OK] == 'on'
        u.seller_profile.availability_template&.destroy
        at = u.seller_profile.build_availability_template(name: 'Availability')
        at.availability_rules.build(open_hour: 6, open_minute: 0, close_hour: 12, close_minute: 0, days: [0, 1, 2, 3, 4]) if array[MORNING] == 'on'
        at.availability_rules.build(open_hour: 12, open_minute: 0, close_hour: 17, close_minute: 0, days: [0, 1, 2, 3, 4]) if array[AFTERNOON] == 'on'
        at.availability_rules.build(open_hour: 17, open_minute: 0, close_hour: 22, close_minute: 0, days: [0, 1, 2, 3, 4]) if array[EVENING] == 'on'
        at.availability_rules.build(open_hour: 6, open_minute: 0, close_hour: 20, close_minute: 0, days: [5, 6]) if array[WEEKEND] == 'on'
        u.seller_profile.properties.overnight_stays = array[OVERNIGHT] == 'on'
        u.seller_profile.properties.cooking = array[COOKING] == 'on'
        u.seller_profile.properties.service_radius = "#{array[DIS_TRAVEL].to_i}km"
        u.default_profile.properties.how_did_you_hear = array[HOWHEAR]
        u.default_profile.properties.accept_newsletter = array[MONTHLY_NEWSLETTER] == 'on'
        u.seller_profile.properties.verification_abn_reference = array[ABNNUM]
        u.created_at = begin
                                       Date.strptime(array[DATE_CREATED], '%m/%d/%Y')
                                     rescue
                                       puts "\tInvalid Date Created: #{array[DATE_CREATED]}"
                                     end || Time.zone.now
        if array[PAY_RATE].to_i > 0
          u.transactables.where(transactable_type: TransactableType.first).destroy_all
          t = u.transactables.where(transactable_type: TransactableType.first).first_or_initialize
          t.name = 'General Care and Support'
          t.currency = 'AUD'
          t.location_not_required = true
          t.description = 'General care and support covering basic mobility assistance and light domestic duties'
          t.properties.ndis_category = ['Assistance with Daily Life', 'Assistance with Social & Community Participation', 'Improved Daily Living Skills', 'Improved Life Choices', 'Increased Social and Community Participation']
          t.properties.services_category = ['Cleaning & Laundry', 'Companionship & Social Support', 'Independent Living skills', 'Meal Preparation & Shopping', 'Showering; Toileting & Dressing']
          t.properties.minor_category = ['Activities, Outings & Community Access', 'Assist with Bowel and Bladder Management', 'Assistance with Eating', 'Cleaning & Laundry', 'Companionship', 'Light Gardening', 'Light Housework', 'Meal Preparation', 'Personal Assistant (Admin)', 'Self careassistance', 'Shopping', 'Showering, Dressing, Grooming', 'Toileting']
          action_type = t.build_time_based_booking(minimum_booking_minutes: 60, transactable_type_action_type: TransactableType::TimeBasedBooking.first, enabled: true)
          t.action_type = action_type
          at = t.action_type.build_availability_template
          at.availability_rules.build(open_hour: 6, open_minute: 0, close_hour: 12, close_minute: 0, days: [0, 1, 2, 3, 4]) if array[MORNING] == 'on'
          at.availability_rules.build(open_hour: 12, open_minute: 0, close_hour: 17, close_minute: 0, days: [0, 1, 2, 3, 4]) if array[AFTERNOON] == 'on'
          at.availability_rules.build(open_hour: 17, open_minute: 0, close_hour: 22, close_minute: 0, days: [0, 1, 2, 3, 4]) if array[EVENING] == 'on'
          at.availability_rules.build(open_hour: 6, open_minute: 0, close_hour: 20, close_minute: 0, days: [5, 6]) if array[WEEKEND] == 'on'
          t.action_type.pricings.build(transactable_type_pricing: TransactableType::Pricing.where(unit: 'hour').first, number_of_units: 1, unit: 'hour', price: array[PAY_RATE])
          raise "Invalid transactable: #{t.errors.full_messages.join(", ")}" unless t.valid?
        end
        u.save!
        raise "For some reason couldn't store user #{u.id} #{u.email}\n#{array.inspect}" unless User.find_by(id: u.id).present?
        u.seller_profile.customizations.each(&:save!)
        if u.metadata['import_email_sent_at'].blank?
          puts "\tSending email to: #{u.email}"
          WorkflowAlert::InvokerFactory.get_invoker(WorkflowAlert.find_by(name: 'Notify carer about import')).invoke!(WorkflowStep::SignUpWorkflow::ListerAccountCreated.new(u.id))
          u.metadata['import_email_sent_at'] = Time.zone.now
          u.save!
        end
      else
        puts "Skipping due to email: #{email}"
      end
    end
    puts "Imported in total: #{emails.count} users"
  end
end
