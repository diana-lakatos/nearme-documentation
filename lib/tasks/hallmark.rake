namespace :hallmark do
  desc 'Setup hallmark'

  task groups: [:environment] do
    instance = Instance.find(5011)
    instance.set_context!

    %w(Public Moderated Private Secret).each do |name|
      group_type = GroupType.where(name: name).first_or_create!

      group_type.custom_validators.where(field_name: 'name').first_or_initialize.tap do |cv|
        cv.max_length = 140
      end.save!

      group_type.custom_validators.where(field_name: 'description').first_or_initialize.tap do |cv|
        cv.max_length = 5000
      end.save!

      group_type.custom_attributes.where(name: 'videos').first_or_initialize.tap do |ca|
        ca.public = true
        ca.html_tag = 'input'
        ca.attribute_type = 'array'
        ca.label = 'Videos'
        ca.hint = 'Enter URL to Youtube or Vimeo video'
        ca.public = true
        ca.searchable = false
      end.save!
    end
  end

  task setup: [:environment] do
    instance = Instance.find(5011)
    instance.set_context!

    WorkflowAlert
      .find_by(instance_id: instance.id, name: 'Member approved email')
      .try(:update_columns,         name: 'Notify user of approved join request',
    template_path: 'group_mailer/notify_user_of_approved_join_request')

    Workflow.find_by(instance_id: instance.id, workflow_type: 'group_workflow').workflow_steps.each do |step|
      step.workflow_alerts.where(alert_type: 'email').each do |alert|
        alert.update!(
          from: 'from@hallmark.com',
          reply_to: 'replyto@hallmark.com'
        )
      end
    end

    Rails.cache.clear
  end

  task import_users: [:environment] do
    instance = Instance.find(5011)
    instance.set_context!
    path = Rails.root.join('marketplaces', 'hallmark', 'users-hallmark.csv')
    mapping = {
      external_id: 0,
      first_name: 1,
      last_name: 2,
      email: 3,
      date_of_birth: 4,
      phone: 5,
      created_at: 6,
      member_since: 7,
      expires_at: 8,
      member_year: 9
    }
    index = 0
    puts "Importing..."
    imported_users = Set.new
    errors = {}
    good_records = []
    CSV.foreach(path) do |array|
      index += 1
      errors[index] = []
      if(index % 200).zero?
        puts "\t\tImported #{index} users"
      end
      if array[mapping.fetch(:email)].blank?
        errors[index] << "Blank email"
      end
      external_id = array[mapping.fetch(:external_id)].strip
      if imported_users.include?(external_id)
        errors[index] << "ID was already used for other record"
      end
      imported_users << external_id
      begin
        email = array[mapping.fetch(:email)].strip.downcase
        u = User.where(email: email).first_or_initialize
        u.get_default_profile
        u.password = SecureRandom.hex(12)
        u.first_name = array[mapping.fetch(:first_name)].strip
        u.last_name = array[mapping.fetch(:last_name)].strip
        u.external_id = external_id
        begin
        u.created_at = Date.parse(array[mapping.fetch(:created_at)])
        rescue
        end
        expires_at = array[mapping.fetch(:expires_at)]
        begin
          u.expires_at = Date.parse("#{expires_at[0..3]}/#{expires_at[4..5]}").end_of_month
        rescue
          errors[index] << "cannot set expire at (#{expires_at})"
          next
        end
        u.mobile_number = array[mapping.fetch(:phone)]
        begin
          date = array[mapping.fetch(:date_of_birth)].to_s
          year = date[-4..-1]
          day = date[-6..-5]
          month = date[0..-7]
          u.default_profile.properties[:date_of_birth] = Date.parse("#{year}-#{month}-#{day}")
        rescue
        end
        member_since = array[mapping.fetch(:member_since)]
        begin
        u.default_profile.properties[:member_since] = Date.parse("#{member_since[0..3]}/#{member_since[4..5]}")
        rescue
        end
        u.default_profile.properties[:member_year] = array[mapping.fetch(:member_year)]
        if u.valid?
          u.save!
        else
          errors[index] << "Invalid rekord: #{u.errors.full_messages.join(', ')}"
        end
      rescue ActiveRecord::RecordInvalid
        puts "\t##{index} - Invalid record #{u.errors.full_messages.join(', ')}"
      end
      if errors[index].empty?
        good_records << index
        puts "\t##{index} - All good!"
      else
        puts "\t##{index} - Had Errors!"
      end
    end
    puts "Good records: #{good_records.count}"
    puts "Errors: "
    puts errors.each do |i, errors|
      puts "##{i}: #{errors.join(';')}"
    end
  end
end
